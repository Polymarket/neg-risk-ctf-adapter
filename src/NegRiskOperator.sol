// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {NegRiskAdapter} from "src/NegRiskAdapter.sol";
import {Auth} from "src/modules/Auth.sol";

/// @title INegRiskOperatorEE
/// @notice NegRiskOperator Errors and Events
// to-do: add events !
interface INegRiskOperatorEE {
    error OnlyOracle();
    error OnlyNegRiskAdapter();
    error InvalidPayouts(uint256[] payouts);
    error OnlyFlagged();
    error OnlyNotFlagged();
    error NotEligibleForEmergencyResolution();
    error DelayPeriodNotOver();
    error ResultNotAvailable();
}

/// @title NegRiskOperator
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

    constructor(address _nrAdapter) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
    }

    function setOracle(address _oracle) external onlyAdmin {
        require(oracle == address(0), "oracle already set");
        oracle = _oracle;
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    function prepareMarket(bytes calldata _data, uint256 _feeBips)
        external
        onlyAdmin
        returns (bytes32)
    {
        return nrAdapter.prepareMarket(_data, _feeBips);
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    function prepareQuestion(bytes32 _marketId, bytes calldata _data, bytes32 _requestId)
        external
        onlyAdmin
        returns (bytes32)
    {
        bytes32 questionId = nrAdapter.prepareQuestion(_marketId, _data);
        questionIds[_requestId] = questionId;
        return questionId;
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT PAYOUTS
    //////////////////////////////////////////////////////////////*/

    // to-do: consider enforcing valid questionId
    // and that it hasnt already been reported
    function reportPayouts(bytes32 _requestId, uint256[] calldata _payouts) external onlyOracle {
        if (_payouts.length != 2) {
            revert InvalidPayouts(_payouts);
        }

        uint256 payout0 = _payouts[0];
        uint256 payout1 = _payouts[1];

        if (payout0 * payout1 != 0) {
            revert InvalidPayouts(_payouts);
        }

        bytes32 questionId = questionIds[_requestId];

        results[questionId] = payout0 == 1 ? true : false;
        reportedAt[questionId] = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                            RESOLVE QUESTION
    //////////////////////////////////////////////////////////////*/

    function resolveQuestion(bytes32 _questionId) external onlyNotFlagged(_questionId) {
        uint256 reportedAt_ = reportedAt[_questionId];

        if (reportedAt_ == 0) revert ResultNotAvailable();
        if (block.timestamp < reportedAt_ + delayPeriod) {
            revert DelayPeriodNotOver();
        }

        bool result = results[_questionId];
        nrAdapter.reportOutcome(_questionId, result);
    }

    /*//////////////////////////////////////////////////////////////
                                 ADMIN
    //////////////////////////////////////////////////////////////*/

    function flagQuestion(bytes32 _questionId) external onlyAdmin onlyNotFlagged(_questionId) {
        flaggedAt[_questionId] = block.timestamp;
    }

    function unflagQuestion(bytes32 _questionId) external onlyAdmin {
        if (flaggedAt[_questionId] == 0) revert OnlyFlagged();
        flaggedAt[_questionId] = 0;
    }

    function emergencyResolveQuestion(bytes32 _questionId, bool _result) external onlyAdmin {
        uint256 flaggedAt_ = flaggedAt[_questionId];

        if (flaggedAt_ == 0) revert OnlyFlagged();
        if (block.timestamp < flaggedAt_ + delayPeriod) {
            revert DelayPeriodNotOver();
        }

        nrAdapter.reportOutcome(_questionId, _result);
    }

    /*//////////////////////////////////////////////////////////////
                                FALLBACK
    //////////////////////////////////////////////////////////////*/

    fallback() external {}
}
