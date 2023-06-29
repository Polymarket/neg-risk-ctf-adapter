// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";

contract NegRiskAdapter_MergePositions_Test is NegRiskAdapter_SetUp {
    function test_mergePositions(uint256 _amount) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice
        vm.startPrank(alice);
        usdc.mint(alice, _amount);
        usdc.approve(address(nrAdapter), _amount);
        nrAdapter.splitPosition(conditionId, _amount);

        uint256 positionIdFalse = nrAdapter.getPositionId(questionId, false);
        ctf.safeTransferFrom(alice, brian, positionIdFalse, _amount, "");

        uint256 positionIdTrue = nrAdapter.getPositionId(questionId, true);
        ctf.safeTransferFrom(alice, brian, positionIdTrue, _amount, "");

        vm.stopPrank();

        vm.startPrank(brian);
        ctf.setApprovalForAll(address(nrAdapter), true);
        nrAdapter.mergePositions(conditionId, _amount);
        vm.stopPrank();

        assertEq(usdc.balanceOf(brian), _amount);
        assertEq(wcol.totalSupply(), 0);
        assertEq(ctf.balanceOf(brian, positionIdFalse), 0);
        assertEq(ctf.balanceOf(brian, positionIdTrue), 0);
    }
}
