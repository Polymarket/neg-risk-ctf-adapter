// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";

contract NegRiskAdapter_PrepareQuestion_Test is NegRiskAdapter_SetUp {
    function test_prepareQuestion() public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);

        uint256 i = 0;

        while (i < 255) {
            nrAdapter.prepareQuestion(marketId, data);
            assertEq(nrAdapter.getQuestionId(marketId, i), bytes32(uint256(marketId) + i));
            assertEq(nrAdapter.getQuestionCount(marketId), i + 1);
            ++i;
        }
    }

    function test_revert_prepareQuestionNotOracle() public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);

        vm.startPrank(alice);
        vm.expectRevert(OnlyOracle.selector);
        nrAdapter.prepareQuestion(marketId, data);
    }
}
