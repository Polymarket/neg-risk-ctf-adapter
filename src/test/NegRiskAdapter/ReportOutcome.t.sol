// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapter_ReportOutcome_Test is TestHelper, INegRiskAdapterEE {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    uint256 constant QUESTION_COUNT = 128;
    bytes32 marketId;

    function setUp() public {
        vault = _getAndLabelAddress("vault");
        oracle = _getAndLabelAddress("oracle");
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        _reportOutcome_setUp();
    }

    function _reportOutcome_setUp() internal {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.startPrank(oracle);
        marketId = nrAdapter.prepareMarket(data, feeBips);

        uint256 i = 0;

        while (i < 128) {
            nrAdapter.prepareQuestion(marketId, data);
            ++i;
        }
    }

    function test_reportOutcomeFalse(uint256 _questionIndex) public {
        _questionIndex = bound(_questionIndex, 0, QUESTION_COUNT - 1);
        bytes32 questionId = nrAdapter.getQuestionId(marketId, _questionIndex);

        // REPORT OUTCOME
        nrAdapter.reportOutcome(questionId, false);

        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        assertEq(ctf.payoutDenominator(conditionId), 1);

        // payouts are [0,1]
        assertEq(ctf.payoutNumerators(conditionId, 0), 0);
        assertEq(ctf.payoutNumerators(conditionId, 1), 1);

        // the market is not determined
        // these are the initial values
        assertEq(nrAdapter.getDetermined(marketId), false);
        assertEq(nrAdapter.getResult(marketId), 0);
    }

    function test_reportOutcomeTrue(uint256 _questionIndex) public {
        _questionIndex = bound(_questionIndex, 0, QUESTION_COUNT - 1);
        bytes32 questionId = nrAdapter.getQuestionId(marketId, _questionIndex);

        // REPORT OUTCOME
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

    function test_revert_reportOutcomeTrueWhenAlreadyDetermined(
        uint256 _questionIndex1,
        uint256 _questionIndex2
    ) public {
        _questionIndex1 = bound(_questionIndex1, 0, QUESTION_COUNT - 1);
        _questionIndex2 = bound(_questionIndex2, 0, QUESTION_COUNT - 1);
        vm.assume(_questionIndex1 != _questionIndex2);

        bytes32 questionId1 = nrAdapter.getQuestionId(marketId, _questionIndex1);
        bytes32 questionId2 = nrAdapter.getQuestionId(marketId, _questionIndex2);

        // REPORT FIRST TRUE OUTCOME
        nrAdapter.reportOutcome(questionId1, true);

        // REPORT SECOND TRUE OUTCOME
        vm.expectRevert(MarketAlreadyDetermined.selector);
        nrAdapter.reportOutcome(questionId2, true);
    }
}
