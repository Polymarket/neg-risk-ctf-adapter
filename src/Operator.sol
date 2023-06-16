// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {NegRiskAdapter} from "./NegRiskAdapter.sol";
import {IUmaCtfAdapter} from "./interfaces/IUmaCtfAdapter.sol";

contract Operator {
    NegRiskAdapter immutable nrAdapter;
    IUmaCtfAdapter immutable umaAdapter;

    // requestId => marketId
    mapping(bytes32 => bytes32) public marketIds;
    // requestId => questionIndex
    mapping(bytes32 => uint256) public questionIndices;

    constructor(address _umaAdapter, address _nrAdapter) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
        umaAdapter = IUmaCtfAdapter(_umaAdapter);
    }

    function prepareQuestion(
        bytes32 _marketId,
        string calldata _metadata,
        bytes calldata _ancillaryData,
        address _rewardToken,
        uint256 _reward,
        uint256 _proposalBond,
        uint256 _liveness
    ) external {
        uint256 index = nrAdapter.prepareQuestion(_marketId, _metadata);
        bytes32 requestId = umaAdapter.initialize(
            _ancillaryData,
            _rewardToken,
            _reward,
            _proposalBond,
            _liveness
        );

        marketIds[requestId] = _marketId;
        questionIndices[requestId] = index;
    }

    function prepareCondition(
        address oracle,
        bytes32 requestId,
        uint256 outcomeSlotCount
    ) external {
        // no-op
    }

    function reportPayouts(
        bytes32 _requestId,
        uint256[] calldata _payouts
    ) external {
        uint256 payout0 = _payouts[0];
        uint256 payout1 = _payouts[0];

        if (payout0 * payout1 != 0) {
            revert("Invalid payouts");
        }

        nrAdapter.reportOutcome(
            marketIds[_requestId],
            questionIndices[_requestId],
            payout1 == 0 ? true : false
        );
    }
}
