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

        vm.startPrank(oracle);
        marketId = nrAdapter.prepareMarket(feeBips, data);

        uint8 i = 0;

        questionId = nrAdapter.prepareQuestion(marketId, data);
        conditionId = nrAdapter.getConditionId(questionId);
    }

    function test_redeemPositions(uint256 _amount) public {
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

        // REPORT OUTCOME
        {
            vm.prank(oracle);
            nrAdapter.reportOutcome(questionId, false);
        }

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

        // bytes32 conditionId = nrAdapter.getConditionId(questionId);
        // assertEq(ctf.payoutDenominator(conditionId), 1);

        // // payouts are [0,1]
        // assertEq(ctf.payoutNumerators(conditionId, 0), 0);
        // assertEq(ctf.payoutNumerators(conditionId, 1), 1);

        // // the market is not determined
        // // these are the initial values
        // assertEq(nrAdapter.getDetermined(marketId), false);
        // assertEq(nrAdapter.getResult(marketId), 0);
    }
}
