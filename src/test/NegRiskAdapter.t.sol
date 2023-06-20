// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapterTest is TestHelper, INegRiskAdapterEE {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    address oracle;
    IConditionalTokens ctf;

    function setUp() public {
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), address(0));
        oracle = _getAndLabelAddress("oracle");
        wcol = nrAdapter.wcol();
    }

    function test_prepareMarket(bytes memory _data, uint256 _feeBips) public {
        _feeBips = bound(_feeBips, 0, 1_00_00);

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(_data, _feeBips);

        assertEq(nrAdapter.getFeeBips(marketId), _feeBips);
        assertEq(nrAdapter.getOracle(marketId), oracle);
        assertEq(nrAdapter.getQuestionCount(marketId), 0);
        assertEq(nrAdapter.getDetermined(marketId), false);
        assertEq(nrAdapter.getResult(marketId), 0);
    }

    function test_revert_prepareMarketTwice(
        bytes memory _data,
        uint256 _feeBips
    ) public {
        _feeBips = bound(_feeBips, 0, 1_00_00);

        vm.startPrank(oracle);
        nrAdapter.prepareMarket(_data, _feeBips);

        vm.expectRevert(MarketAlreadyPrepared.selector);
        nrAdapter.prepareMarket(_data, _feeBips);
    }

    function test_prepareQuestion() public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);

        uint256 i = 0;

        while (i < 255) {
            nrAdapter.prepareQuestion(marketId, data);
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

    function test_splitPosition(uint256 _amount) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice
        vm.startPrank(alice);
        usdc.mint(alice, _amount);
        usdc.approve(address(nrAdapter), _amount);
        nrAdapter.splitPosition(conditionId, _amount);

        // check collateral balances
        assertEq(usdc.balanceOf(address(wcol)), _amount);
        assertEq(wcol.totalSupply(), _amount);
        assertEq(wcol.balanceOf(address(ctf)), _amount);

        // check position token balances
        uint256 positionIdFalse = nrAdapter.computePositionId(
            questionId,
            false
        );
        assertEq(ctf.balanceOf(alice, positionIdFalse), _amount);

        uint256 positionIdTrue = nrAdapter.computePositionId(questionId, true);
        assertEq(ctf.balanceOf(alice, positionIdTrue), _amount);
    }

    function test_mergePositions(uint256 _amount) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice
        vm.startPrank(alice);
        usdc.mint(alice, _amount);
        usdc.approve(address(nrAdapter), _amount);
        nrAdapter.splitPosition(conditionId, _amount);

        uint256 positionIdFalse = nrAdapter.computePositionId(
            questionId,
            false
        );
        ctf.safeTransferFrom(alice, brian, positionIdFalse, _amount, "");

        uint256 positionIdTrue = nrAdapter.computePositionId(questionId, true);
        ctf.safeTransferFrom(alice, brian, positionIdTrue, _amount, "");

        vm.stopPrank();

        vm.startPrank(brian);
        ctf.setApprovalForAll(address(nrAdapter), true);
        nrAdapter.mergePositions(conditionId, _amount);
        vm.stopPrank();

        assertEq(usdc.balanceOf(brian), _amount);
        assertEq(wcol.totalSupply(), 0);
        assertEq(ctf.balanceOf(brian, positionIdFalse), 0);
        assertEq(ctf.balanceOf(brian, positionIdTrue), 0);
    }
}
