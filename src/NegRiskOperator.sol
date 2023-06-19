// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {NegRiskAdapter} from "./NegRiskAdapter.sol";
import {IUmaCtfAdapter} from "./interfaces/IUmaCtfAdapter.sol";
import {Auth} from "./modules/Auth.sol";

interface INegRiskOperatorEE {
    error OnlyUmaAdapter();
    error OnlyNegRiskAdapter();
}

contract NegRiskOperator is INegRiskOperatorEE, Auth {
    NegRiskAdapter immutable nrAdapter;
    IUmaCtfAdapter immutable umaAdapter;

    modifier onlyUmaAdapter() {
        if (msg.sender != address(umaAdapter)) revert OnlyUmaAdapter();
        _;
    }

    mapping(bytes32 _requestId => bytes32 questionId) public questionIds;

    constructor(address _umaAdapter, address _nrAdapter) {
        nrAdapter = NegRiskAdapter(_nrAdapter);
        umaAdapter = IUmaCtfAdapter(_umaAdapter);
    }

    function prepareMarket(
        bytes memory _data,
        uint256 _feeBips
    ) external onlyAdmin returns (bytes32) {
        return nrAdapter.prepareMarket(_data, _feeBips);
    }

    function prepareQuestion(
        bytes32 _marketId,
        bytes calldata _data,
        bytes calldata _ancillaryData,
        address _rewardToken,
        uint256 _reward,
        uint256 _proposalBond,
        uint256 _liveness
    ) external onlyAdmin {
        bytes32 questionId = nrAdapter.prepareQuestion(_marketId, _data);
        bytes32 requestId = umaAdapter.initialize(
            _ancillaryData,
            _rewardToken,
            _reward,
            _proposalBond,
            _liveness
        );
        questionIds[requestId] = questionId;
    }

    function reportPayouts(
        bytes32 _requestId,
        uint256[] calldata _payouts
    ) external onlyUmaAdapter {
        uint256 payout0 = _payouts[0];
        uint256 payout1 = _payouts[1];

        if (payout0 * payout1 != 0) {
            revert("Invalid payouts");
        }

        bytes32 questionId = questionIds[_requestId];

        nrAdapter.reportOutcome(questionId, payout1 == 0 ? true : false);
    }

    fallback() external {}
}
