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
    address public immutable oracle;
    uint256 public constant delayPeriod = 2 hours;

    mapping(bytes32 _requestId => bytes32) public questionIds;
    mapping(bytes32 _questionId => bool) public results;
    mapping(bytes32 _questionId => bool) public flagged;
    mapping(bytes32 _questionId => uint256) public reportedAt;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOracle() {
        if (msg.sender != oracle) revert OnlyOracle();
        _;
    }

    modifier onlyFlagged(bytes32 _questionId) {
        if (!flagged[_questionId]) revert OnlyFlagged();
    }

    modifier onlyNotFlagged(bytes32 _questionId) {
        if (flagged[_questionId]) revert OnlyNotFlagged();
    }

    // to-do: add onlyResultReceivedAndDelayOver

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _nrAdapter, address _oracle) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
        oracle = _oracle;
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    function prepareMarket(
        bytes calldata _data,
        uint256 _feeBips
    ) external onlyAdmin returns (bytes32) {
        return nrAdapter.prepareMarket(_data, _feeBips);
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    function prepareQuestion(
        bytes32 _marketId,
        bytes calldata _data,
        bytes32 _requestId
    ) external onlyAdmin {
        bytes32 questionId = nrAdapter.prepareQuestion(_marketId, _data);
        questionIds[_requestId] = questionId;
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT PAYOUTS
    //////////////////////////////////////////////////////////////*/

    function reportPayouts(
        bytes32 _requestId,
        uint256[] calldata _payouts
    ) external onlyOracle {
        uint256 payout0 = _payouts[0];
        uint256 payout1 = _payouts[1];

        if ((_payouts.length != 2) || (payout0 * payout1 != 0)) {
            revert InvalidPayouts(_payouts);
        }

        bytes32 questionId = questionIds[_requestId];
        results[questionId] = payout1 == 0 ? true : false;
        reportedAt[questionId] = block.timestamp;
    }

    /*//////////////////////////////////////////////////////////////
                            RESOLVE QUESTION
    //////////////////////////////////////////////////////////////*/

    function resolveQuestion(
        bytes32 _questionId
    ) external onlyNotFlagged(_questionId) {
        uint256 reportedAt = reportedAt[_questionId];

        if (reportedAt == 0) revert ResultNotAvailable();
        if (block.timestamp < reportedAt + delayPeriod)
            revert DelayPeriodNotOver();

        bool result = results[_questionId];
        nrAdapter.reportOutcome(_questionId, result);
    }

    /*//////////////////////////////////////////////////////////////
                             FLAG QUESTION
    //////////////////////////////////////////////////////////////*/

    function flagQuestion(
        bytes32 _questionId
    ) external onlyAdmin onlyNotFlagged(_questionId) {
        flagged[_questionId] = true;
    }

    /*//////////////////////////////////////////////////////////////
                            UNFLAG QUESTION
    //////////////////////////////////////////////////////////////*/

    function unflagQuestion(
        bytes32 _questionId
    ) external onlyAdmin onlyFlagged(_questionId) {
        flags[_questionId] = 0;
    }

    /*//////////////////////////////////////////////////////////////
                           EMERGENCY RESOLVE
    //////////////////////////////////////////////////////////////*/

    // to-do: handle the case where reportPayouts reverts bc payouts is [1,1]
    function emergencyResolve(
        bytes32 _questionId,
        bool _result
    ) external onlyAdmin onlyFlagged(_questionId) {
        uint256 reportedAt = reportedAt[_questionId];

        if (block.timestamp < reportedAt + delayPeriod)
            revert DelayPeriodNotOver();

        nrAdapter.reportOutcome(_questionId, _result);
    }

    /*//////////////////////////////////////////////////////////////
                                FALLBACK
    //////////////////////////////////////////////////////////////*/

    fallback() external {}
}
