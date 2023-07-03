// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapter_RedeemPositions_Test is NegRiskAdapter_SetUp {
    bytes32 marketId;
    bytes32 questionId;
    bytes32 conditionId;

    function setUp() public override {
        NegRiskAdapter_SetUp.setUp();

        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare a market with a single question
        {
            vm.startPrank(oracle);
            marketId = nrAdapter.prepareMarket(feeBips, data);
            questionId = nrAdapter.prepareQuestion(marketId, data);
            conditionId = nrAdapter.getConditionId(questionId);
        }
    }

    function test_redeemPositions(uint256 _amount) public {
        // split position to alice
        // distribute yes positions to brian
        // distribute no positions to carly
        {
            vm.startPrank(alice);
            usdc.mint(alice, _amount);
            usdc.approve(address(nrAdapter), _amount);
            nrAdapter.splitPosition(conditionId, _amount);

            uint256 positionIdTrue = nrAdapter.getPositionId(questionId, true);
            uint256 positionIdFalse = nrAdapter.getPositionId(questionId, false);

            ctf.safeTransferFrom(alice, brian, positionIdTrue, _amount, "");
            ctf.safeTransferFrom(alice, carly, positionIdFalse, _amount, "");
            vm.stopPrank();
        }

        // report outcome as false
        {
            vm.prank(oracle);
            nrAdapter.reportOutcome(questionId, false);
        }

        // redeem worthless positions
        {
            vm.startPrank(brian);
            ctf.setApprovalForAll(address(nrAdapter), true);
            uint256[] memory amounts = new uint256[](2);
            amounts[0] = _amount;
            nrAdapter.redeemPositions(conditionId, amounts);
            // these were worthless
            assertEq(usdc.balanceOf(brian), 0);
            vm.stopPrank();
        }

        // redeem valuable positions
        {
            vm.startPrank(carly);
            ctf.setApprovalForAll(address(nrAdapter), true);
            uint256[] memory amounts = new uint256[](2);
            amounts[1] = _amount;
            nrAdapter.redeemPositions(conditionId, amounts);
            // these were worthless
            assertEq(usdc.balanceOf(carly), _amount);
            vm.stopPrank();
        }
    }
}
