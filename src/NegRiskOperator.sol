// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {NegRiskAdapter} from "src/NegRiskAdapter.sol";
import {Auth} from "src/modules/Auth.sol";
import {IAuthEE} from "src/modules/interfaces/IAuth.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

/// @title INegRiskOperatorEE
/// @notice NegRiskOperator Errors and Events
interface INegRiskOperatorEE is IAuthEE {
    error OnlyOracle();
    error OracleAlreadyInitialized();
    error OnlyNegRiskAdapter();
    error InvalidPayouts();
    error OnlyFlagged();
    error OnlyNotFlagged();
    error NotEligibleForEmergencyResolution();
    error DelayPeriodNotOver();
    error ResultNotAvailable();
    error QuestionWithRequestIdAlreadyPrepared();
    error InvalidRequestId();
    error QuestionAlreadyReported();

    event MarketPrepared(bytes32 indexed marketId, uint256 feeBips, bytes data);
    event QuestionPrepared(
        bytes32 indexed marketId,
        bytes32 indexed questionId,
        bytes32 indexed requestId,
        uint256 questionIndex,
        bytes data
    );
    event QuestionFlagged(bytes32 indexed questionId);
    event QuestionUnflagged(bytes32 indexed questionId);
    event QuestionReported(bytes32 indexed questionId, bytes32 requestId, bool result);
    event QuestionResolved(bytes32 indexed questionId, bool result);
    event QuestionEmergencyResolved(bytes32 indexed questionId, bool result);
}

/// @title NegRiskOperator
/// @notice Permissioned Operator for interacting with the NegRiskAdapter
/// @author Mike Shrieve (mike@polymarket.com)
contract NegRiskOperator is INegRiskOperatorEE, Auth {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    NegRiskAdapter public immutable nrAdapter;
    address public oracle;
    uint256 public constant delayPeriod = 2 hours;

    mapping(bytes32 _requestId => bytes32) public questionIds;
    mapping(bytes32 _questionId => bool) public results;
    mapping(bytes32 _questionId => uint256) public flaggedAt;
    mapping(bytes32 _questionId => uint256) public reportedAt;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOracle() {
        if (msg.sender != oracle) revert OnlyOracle();
        _;
    }

    modifier onlyNotFlagged(bytes32 _questionId) {
        if (flaggedAt[_questionId] > 0) revert OnlyNotFlagged();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _nrAdapter - the address of the NegRiskAdapter
    constructor(address _nrAdapter) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
    }

    /// @notice Sets the oracle address
    /// @notice OnlyAdmin
    /// @notice Can only be called once
    /// @param _oracle - the address of the oracle
    function setOracle(address _oracle) external onlyAdmin {
        if (oracle != address(0)) revert OracleAlreadyInitialized();
        oracle = _oracle;
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepares a market on the NegRiskAdapter
    /// @param _feeBips - the market's fee rate out of 1_00_00
    /// @param _data - the market metadata to be passed to the NegRiskAdapter
    /// @return marketId - the market id
    function prepareMarket(uint256 _feeBips, bytes calldata _data) external onlyAdmin returns (bytes32) {
        bytes32 marketId = nrAdapter.prepareMarket(_feeBips, _data);
        emit MarketPrepared(marketId, _feeBips, _data);
        return marketId;
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepares a question on the NegRiskAdapter
    /// @notice OnlyAdmin
    /// @notice Only one question can be prepared per requestId
    /// @param _marketId - the id of the market in which to prepare the question
    /// @param _data - the question metadata to be passed to the NegRiskAdapter
    /// @param _requestId - the question's oracle request id
    function prepareQuestion(bytes32 _marketId, bytes calldata _data, bytes32 _requestId)
        external
        onlyAdmin
        returns (bytes32)
    {
        if (questionIds[_requestId] != bytes32(0)) {
            revert QuestionWithRequestIdAlreadyPrepared();
        }

        bytes32 questionId = nrAdapter.prepareQuestion(_marketId, _data);

        questionIds[_requestId] = questionId;

        emit QuestionPrepared(_marketId, questionId, _requestId, NegRiskIdLib.getQuestionIndex(questionId), _data);
        return questionId;
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT PAYOUTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Reports the outcome for a question
    /// @notice OnlyOracle
    /// @notice Only one report can be made per question
    /// @notice Sets the boolean result and reportedAt timestamp for the question
    /// @param _requestId - the question's oracle request id
    /// @param _payouts - the payouts to be reported, [1,0] if true, [0,1] if false, any other payouts are invalid
    function reportPayouts(bytes32 _requestId, uint256[] calldata _payouts) external onlyOracle {
        if (_payouts.length != 2) {
            revert InvalidPayouts();
        }

        uint256 payout0 = _payouts[0];
        uint256 payout1 = _payouts[1];

        if (payout0 + payout1 != 1) {
            revert InvalidPayouts();
        }

        bytes32 questionId = questionIds[_requestId];

        if (questionId == bytes32(0)) {
            revert InvalidRequestId();
        }

        if (reportedAt[questionId] > 0) {
            revert QuestionAlreadyReported();
        }

        bool result = payout0 == 1 ? true : false;
        uint256 reportedAt_ = block.timestamp;

        results[questionId] = payout0 == 1 ? true : false;
        reportedAt[questionId] = block.timestamp;

        emit QuestionReported(questionId, _requestId, result);
    }

    /*//////////////////////////////////////////////////////////////
                            RESOLVE QUESTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Resolves a question on the NegRiskAdapter
    /// @notice OnlyNotFlagged
    /// @notice A question can only be resolved if the delay period has passed since the question was reported
    /// @param _questionId - the id of the question to be resolved
    function resolveQuestion(bytes32 _questionId) external onlyNotFlagged(_questionId) {
        uint256 reportedAt_ = reportedAt[_questionId];

        if (reportedAt_ == 0) revert ResultNotAvailable();
        if (block.timestamp < reportedAt_ + delayPeriod) {
            revert DelayPeriodNotOver();
        }

        bool result = results[_questionId];
        nrAdapter.reportOutcome(_questionId, result);

        emit QuestionResolved(_questionId, result);
    }

    /*//////////////////////////////////////////////////////////////
                                 ADMIN
    //////////////////////////////////////////////////////////////*/

    /// @notice Flags a question, preventing it from being resolved
    /// @param _questionId - the id of the question to be flagged
    function flagQuestion(bytes32 _questionId) external onlyAdmin onlyNotFlagged(_questionId) {
        flaggedAt[_questionId] = block.timestamp;
        emit QuestionFlagged(_questionId);
    }

    /// @notice Unflags a question, allowing it to be resolved normally
    /// @param _questionId - the id of the question to be unflagged
    function unflagQuestion(bytes32 _questionId) external onlyAdmin {
        if (flaggedAt[_questionId] == 0) revert OnlyFlagged();
        flaggedAt[_questionId] = 0;
        emit QuestionUnflagged(_questionId);
    }

    /// @notice Resolves a flagged question on the NegRiskAdapter
    /// @notice OnlyAdmin
    /// @notice A flagged question can only be resolved if the delay period has passed since the question was flagged
    function emergencyResolveQuestion(bytes32 _questionId, bool _result) external onlyAdmin {
        uint256 flaggedAt_ = flaggedAt[_questionId];

        if (flaggedAt_ == 0) revert OnlyFlagged();
        if (block.timestamp < flaggedAt_ + delayPeriod) {
            revert DelayPeriodNotOver();
        }

        nrAdapter.reportOutcome(_questionId, _result);
        emit QuestionEmergencyResolved(_questionId, _result);
    }

    /*//////////////////////////////////////////////////////////////
                                 NO-OP
    //////////////////////////////////////////////////////////////*/

    /// @notice Allows the Oracle to treat the Operator like the CTF, i.e., to call prepareCondition
    function prepareCondition(address, bytes32, uint256) external {
        // no-op
    }
}
