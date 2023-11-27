// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapter_ReportOutcome_Test is NegRiskAdapter_SetUp {
    uint8 constant QUESTION_COUNT = 128;
    bytes32 marketId;

    function setUp() public override {
        NegRiskAdapter_SetUp.setUp();

        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        vm.startPrank(oracle);
        marketId = nrAdapter.prepareMarket(feeBips, data);

        uint8 i = 0;

        while (i < 128) {
            nrAdapter.prepareQuestion(marketId, data);
            ++i;
        }
        vm.stopPrank();
    }

    function test_reportOutcome(uint8 _questionIndex, bool _result) public {
        _questionIndex %= QUESTION_COUNT;
        bytes32 questionId = NegRiskIdLib.getQuestionId(marketId, uint8(_questionIndex));

        // REPORT OUTCOME
        vm.prank(oracle);
        nrAdapter.reportOutcome(questionId, _result);

        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        assertEq(ctf.payoutDenominator(conditionId), 1);

        // payouts are [0,1]
        assertEq(ctf.payoutNumerators(conditionId, 0), _result ? 1 : 0);
        assertEq(ctf.payoutNumerators(conditionId, 1), _result ? 0 : 1);

        if (_result == true) {
            assertEq(nrAdapter.getDetermined(marketId), true);
            assertEq(nrAdapter.getResult(marketId), _questionIndex);
        } else {
            assertEq(nrAdapter.getDetermined(marketId), false);
            assertEq(nrAdapter.getResult(marketId), 0);
        }
    }

    function test_reportOutcomeTrue(uint8 _questionIndex) public {
        _questionIndex %= QUESTION_COUNT;
        bytes32 questionId = NegRiskIdLib.getQuestionId(marketId, uint8(_questionIndex));

        // REPORT OUTCOME
        vm.prank(oracle);
        nrAdapter.reportOutcome(questionId, true);

        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        assertEq(ctf.payoutDenominator(conditionId), 1);

        // payouts are [1,0]
        assertEq(ctf.payoutNumerators(conditionId, 0), 1);
        assertEq(ctf.payoutNumerators(conditionId, 1), 0);

        // the market is now determined
        assertEq(nrAdapter.getDetermined(marketId), true);
        assertEq(nrAdapter.getResult(marketId), _questionIndex);
    }

    function test_revert_reportOutcome_marketAlreadyDetermined(uint8 _questionIndex1, uint8 _questionIndex2) public {
        _questionIndex1 %= QUESTION_COUNT;
        _questionIndex2 %= QUESTION_COUNT;

        vm.assume(_questionIndex1 != _questionIndex2);

        bytes32 questionId1 = NegRiskIdLib.getQuestionId(marketId, _questionIndex1);
        bytes32 questionId2 = NegRiskIdLib.getQuestionId(marketId, _questionIndex2);

        // REPORT FIRST TRUE OUTCOME
        vm.prank(oracle);
        nrAdapter.reportOutcome(questionId1, true);

        // REPORT SECOND TRUE OUTCOME
        vm.expectRevert(MarketAlreadyDetermined.selector);
        vm.prank(oracle);
        nrAdapter.reportOutcome(questionId2, true);
    }

    function test_revert_reportOutcome_marketNotPrepared(bytes32 _questionId, bool _result) public {
        vm.assume(NegRiskIdLib.getMarketId(_questionId) != marketId);

        vm.expectRevert(MarketNotPrepared.selector);
        nrAdapter.reportOutcome(_questionId, _result);
    }

    function test_revert_reportOutcome_onlyOracle(uint8 _questionIndex, bool _result) public {
        _questionIndex %= QUESTION_COUNT;
        bytes32 questionId = NegRiskIdLib.getQuestionId(marketId, uint8(_questionIndex));

        vm.expectRevert(OnlyOracle.selector);
        nrAdapter.reportOutcome(questionId, _result);
    }

    function test_revert_reportOutcome_indexOutOfBounds(uint256 _questionIndex, bool _result) public {
        _questionIndex = bound(_questionIndex, QUESTION_COUNT, type(uint8).max);
        bytes32 questionId = NegRiskIdLib.getQuestionId(marketId, uint8(_questionIndex));

        vm.expectRevert(IndexOutOfBounds.selector);
        vm.prank(oracle);
        nrAdapter.reportOutcome(questionId, _result);
    }
}
