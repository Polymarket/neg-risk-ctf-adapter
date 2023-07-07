// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapter_PrepareQuestion_Test is NegRiskAdapter_SetUp {
    function test_prepareQuestion() public {
        uint256 feeBips = 0;

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, "market");

        uint8 i = 0;

        while (i < 255) {
            bytes memory data = abi.encodePacked("question", i);
            vm.expectEmit();
            emit QuestionPrepared(marketId, NegRiskIdLib.getQuestionId(marketId, i), i, data);
            nrAdapter.prepareQuestion(marketId, data);
            assertEq(NegRiskIdLib.getQuestionId(marketId, i), bytes32(uint256(marketId) + i));
            assertEq(nrAdapter.getQuestionCount(marketId), i + 1);
            ++i;
        }
    }

    function test_revert_prepareQuestion_onlyOracle() public {
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        vm.startPrank(alice);
        vm.expectRevert(OnlyOracle.selector);
        nrAdapter.prepareQuestion(marketId, data);
    }

    function test_revert_prepareQuestion_marketNotPrepared(bytes32 _marketId) public {
        bytes memory data = bytes("question");

        vm.expectRevert(MarketNotPrepared.selector);
        vm.prank(oracle);
        nrAdapter.prepareQuestion(_marketId, data);
    }
}
