// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";

contract NegRiskAdapter_SplitPosition_Test is NegRiskAdapter_SetUp {
    function test_splitPosition(uint256 _amount) public {
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

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
        vm.stopPrank();

        // check collateral balances
        assertEq(usdc.balanceOf(address(wcol)), _amount);
        assertEq(wcol.totalSupply(), _amount);
        assertEq(wcol.balanceOf(address(ctf)), _amount);

        // check position token balances
        uint256 positionIdFalse = nrAdapter.getPositionId(questionId, false);
        assertEq(ctf.balanceOf(alice, positionIdFalse), _amount);
        uint256 positionIdTrue = nrAdapter.getPositionId(questionId, true);
        assertEq(ctf.balanceOf(alice, positionIdTrue), _amount);
    }
}
