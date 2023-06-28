// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TestHelper, console} from "../dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {NegRiskOperator} from "src/NegRiskOperator.sol";

contract NegRiskOperatorTest is TestHelper {
    NegRiskAdapter nrAdapter;
    NegRiskOperator nrOperator;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    uint256[] payoutsTrue = [1, 0];
    uint256[] payoutsFalse = [0, 1];

    function setUp() public {
        vault = _getAndLabelAddress("vault");
        oracle = _getAndLabelAddress("oracle");
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        vm.prank(alice);
        nrOperator = new NegRiskOperator(address(nrAdapter), oracle);
    }

    function test_initialState() public {
        assertEq(nrOperator.oracle(), oracle);
        assertEq(address(nrOperator.nrAdapter()), address(nrAdapter));
        assertEq(nrOperator.isAdmin(alice), true);
    }

    function test_prepareMarket(bytes memory _data, uint256 _feeBips) public {
        _feeBips = bound(_feeBips, 0, 1_00_00);

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(_data, _feeBips);

        assertEq(marketId, nrAdapter.getMarketId(address(nrOperator), _data));
        assertEq(nrAdapter.getFeeBips(marketId), _feeBips);
        assertEq(nrAdapter.getOracle(marketId), address(nrOperator));
        assertEq(nrAdapter.getQuestionCount(marketId), 0);
    }

    function test_prepareQuestion(bytes32 _requestId) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(data, feeBips);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        assertEq(nrAdapter.getQuestionCount(marketId), 1);
        assertEq(nrAdapter.getMarketId(questionId), marketId);
    }

    function test_reportPayouts(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(data, feeBips);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        assertEq(nrOperator.results(questionId), _result);
        assertEq(nrOperator.reportedAt(questionId), block.timestamp);
    }

    function test_resolveQuestion(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(data, feeBips);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        skip(nrOperator.delayPeriod());
        nrOperator.resolveQuestion(questionId);

        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        assertEq(ctf.payoutDenominator(conditionId), 1);
        assertEq(ctf.payoutNumerators(conditionId, 0), _result ? 1 : 0);
        assertEq(ctf.payoutNumerators(conditionId, 1), _result ? 0 : 1);
    }

    function test_flagQuestion(bytes32 _questionId) public {
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);

        assertEq(nrOperator.flaggedAt(_questionId), block.timestamp);
    }

    function test_unflagQuestion(bytes32 _questionId) public {
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);

        vm.prank(alice);
        nrOperator.unflagQuestion(_questionId);

        assertEq(nrOperator.flaggedAt(_questionId), 0);
    }

    function test_emergencyResolveQuestion(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(data, feeBips);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(alice);
        nrOperator.flagQuestion(questionId);

        skip(nrOperator.delayPeriod());

        vm.prank(alice);
        nrOperator.emergencyResolveQuestion(questionId, _result);
    }
}
