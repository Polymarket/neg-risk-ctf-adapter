// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";

contract NegRiskAdapter_PrepareQuestion_Test is NegRiskAdapter_SetUp {
    function test_prepareQuestion() public {
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;

        while (i < 255) {
            nrAdapter.prepareQuestion(marketId, data);
            assertEq(nrAdapter.getQuestionId(marketId, i), bytes32(uint256(marketId) + i));
            assertEq(nrAdapter.getQuestionCount(marketId), i + 1);
            ++i;
        }
    }

    function test_revert_prepareQuestionNotOracle() public {
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        vm.startPrank(alice);
        vm.expectRevert(OnlyOracle.selector);
        nrAdapter.prepareQuestion(marketId, data);
    }
}
