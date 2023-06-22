// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {NegRiskAdapter} from "./NegRiskAdapter.sol";
import {Auth} from "./modules/Auth.sol";

interface INegRiskOperatorEE {
    error OnlyOracle();
    error OnlyNegRiskAdapter();
    error InvalidPayouts(uint256[] payouts);
    error Flagged();
    error NotEligibleForEmergencyResolution();
}

contract NegRiskOperator is INegRiskOperatorEE, Auth {
    NegRiskAdapter immutable nrAdapter;
    address immutable oracle;

    uint256 public constant emergencyResolutionDelay = 2 hours;

    modifier onlyOracle() {
        if (msg.sender != oracle) revert OnlyOracle();
        _;
    }

    mapping(bytes32 _requestId => bytes32) public questionIds;

    // 0: unreported
    // 1: true
    // 2: false
    mapping(bytes32 _questionId => uint256) public results;
    mapping(bytes32 _questionId => uint256) public flags;

    constructor(address _nrAdapter, address _oracle) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
        oracle = _oracle;
    }

    function prepareMarket(
        bytes calldata _data,
        uint256 _feeBips
    ) external onlyAdmin returns (bytes32) {
        return nrAdapter.prepareMarket(_data, _feeBips);
    }

    function prepareQuestion(
        bytes32 _marketId,
        bytes calldata _data,
        bytes32 _requestId
    ) external onlyAdmin {
        bytes32 questionId = nrAdapter.prepareQuestion(_marketId, _data);
        questionIds[_requestId] = questionId;
    }

    function resolveQuestion(bytes32 _questionId) external onlyAdmin {
        nrAdapter.reportOutcome(questionId, payout1 == 0 ? true : false);
    }

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
        results[questionId] = payout1 == 0 ? 1 : 2;
        // nrAdapter.reportOutcome(questionId, payout1 == 0 ? true : false);
    }

    function resolveQuestion(bytes32 _questionId) external onlyAdmin {
        uint256 result = results[_questionId];

        if (result == 0) revert InvalidResult();
        if (flags[_questionId] != 0) revert Flagged();

        nrAdapter.reportOutcome(
            _questionId,
            results[_questionId] == 1 ? true : false
        );
    }

    function flagQuestion(bytes32 _questionId) external onlyAdmin {
        flags[_questionId] = block.timestamp;
    }

    function unflagQuestion(bytes32 _questionId) external onlyAdmin {
        flags[_questionId] = 0;
    }

    function emergencyResolveQuestion(
        bytes32 _questionId,
        bool _result
    ) external onlyAdmin {
        if (block.timestamp < flags[_questionId] + emergencyResolutionDelay)
            revert NotEligibleForEmergencyResolution();

        nrAdapter.reportOutcome(_questionId, _result);
    }

    fallback() external {}
}
