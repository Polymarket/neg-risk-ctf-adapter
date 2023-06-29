// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapterTest is NegRiskAdapter_SetUp {
    function test_convertPositions(uint256 _a, uint256 _b, uint128 _amount) public {
        vm.assume(_amount > 0);

        bytes memory data = new bytes(0);
        // 10%
        uint256 feeBips = 10_000;

        uint256 questionCountMax = 16;
        uint256 questionCount = bound(_a, 2, questionCountMax); // between 2 and 16 questions
        uint256 indexSet = bound(_b, 1, (2 ** questionCount) - 1);
        uint256 noPositionsCount;

        // prepare market
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint8 i = 0;

        // prepare questions and split initial liquidity to alice
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, _amount);
            usdc.approve(address(nrAdapter), _amount);
            nrAdapter.splitPosition(conditionId, _amount);
            vm.stopPrank();

            ++i;
        }

        assertEq(nrAdapter.getQuestionCount(marketId), questionCount);

        // send no positions to brian
        {
            i = 0;

            while (i < questionCount) {
                if (indexSet & (1 << i) > 0) {
                    uint256 positionId =
                        nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), false);
                    ctf.balanceOf(alice, positionId);
                    vm.prank(alice);
                    ctf.safeTransferFrom(alice, brian, positionId, _amount, "");
                    assertEq(ctf.balanceOf(brian, positionId), _amount);
                }
                ++i;
            }
        }

        vm.startPrank(brian);
        ctf.setApprovalForAll(address(nrAdapter), true);

        // convert positions
        nrAdapter.convertPositions(marketId, indexSet, _amount);

        // check balances
        {
            uint256 feeAmount = (_amount * feeBips) / 1_00_00;
            uint256 amountOut = _amount - feeAmount;

            i = 0;
            while (i < questionCount) {
                if (indexSet & (1 << i) > 0) {
                    // NO

                    uint256 positionId =
                        nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), false);

                    // brian has no more of this no token
                    assertEq(ctf.balanceOf(brian, positionId), 0);
                    // they are all at the no token burn address
                    assertEq(ctf.balanceOf(nrAdapter.noTokenBurnAddress(), positionId), _amount);
                    ++noPositionsCount;
                } else {
                    // YES
                    uint256 positionId =
                        nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), true);

                    // brian has _amount of each yes token, after fees
                    assertEq(ctf.balanceOf(brian, positionId), _amount - feeAmount);
                    // vault has the rest of yes tokens as fees
                    assertEq(ctf.balanceOf(vault, positionId), feeAmount);
                }
                ++i;
            }

            // brian should have (noPositionsCount -1) * amountOut USDC
            assertEq(usdc.balanceOf(brian), (noPositionsCount - 1) * amountOut);
        }
    }
}
