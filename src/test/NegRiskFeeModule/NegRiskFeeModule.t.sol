// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Test} from "../../../lib/forge-std/src/Test.sol";
import {Side} from "../../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";
import {IConditionalTokens, ICTFExchange, IERC20, IFeeModule, INegRiskAdapter} from "../../interfaces/index.sol";
import {AddressLib} from "../../dev/libraries/AddressLib.sol";
import {NegRiskFeeModuleTestHelper} from "./NegRiskFeeModuleTestHelper.sol";

contract NegRiskFeeModule_Test is NegRiskFeeModuleTestHelper {
    function setUp() public {
        marketId = INegRiskAdapter(negRiskAdapter).prepareMarket(0, "test_market");
        questionId = INegRiskAdapter(negRiskAdapter).prepareQuestion(marketId, "test_market");
        conditionId = INegRiskAdapter(negRiskAdapter).getConditionId(questionId);

        yesPositionId = INegRiskAdapter(negRiskAdapter).getPositionId(questionId, true);
        noPositionId = INegRiskAdapter(negRiskAdapter).getPositionId(questionId, false);

        vm.prank(admin.addr);
        ICTFExchange(negRiskCtfExchange).registerToken(yesPositionId, noPositionId, conditionId);
    }

    function test_NegRiskFeeModule_matchOrders_buySell() public {
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // alice approvals
        vm.startPrank(alice.addr);
        IERC20(usdc).approve(negRiskCtfExchange, TOKEN_AMOUNT);
        vm.stopPrank();

        // brian approvals
        vm.startPrank(brian.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // split initial tokens + usdc distribution
        vm.startPrank(carly.addr);
        _dealERC20(usdc, carly.addr, TOKEN_AMOUNT);
        IERC20(usdc).approve(negRiskAdapter, TOKEN_AMOUNT);
        INegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, TOKEN_AMOUNT);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        // deal USDC to alice
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);
        // transfer yes tokens to brian
        INegRiskAdapter(negRiskAdapter).safeTransferFrom(carly.addr, brian.addr, yesPositionId, TOKEN_AMOUNT, "");
        vm.stopPrank();

        // sign alice order
        ICTFExchange.Order memory aliceOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: USDC_AMOUNT,
            _takerAmount: TOKEN_AMOUNT,
            _side: Side.BUY
        });

        // sign brian order
        ICTFExchange.Order memory brianOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: brian.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: TOKEN_AMOUNT,
            _takerAmount: USDC_AMOUNT,
            _side: Side.SELL
        });

        // takerOrder + takerFillAmount
        ICTFExchange.Order memory takerOrder = aliceOrder;
        uint256 takerFillAmount = USDC_AMOUNT;

        // makerOrders + makerFillAmounts
        ICTFExchange.Order[] memory makerOrders = new ICTFExchange.Order[](1);
        makerOrders[0] = brianOrder;
        uint256[] memory makerFillAmounts = new uint256[](1);
        makerFillAmounts[0] = TOKEN_AMOUNT;

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(brian.addr), 0);

        // -- MATCH ORDERS --
        vm.prank(operator.addr);
        IFeeModule(negRiskFeeModule).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts, 0);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }

    function test_NegRiskFeeModule_matchOrders_sellBuy() public {
        // simply swap alice and brians orders
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // alice approvals
        vm.startPrank(alice.addr);
        IERC20(usdc).approve(negRiskCtfExchange, TOKEN_AMOUNT);
        vm.stopPrank();

        // brian approvals
        vm.startPrank(brian.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // split initial tokens + usdc distribution
        vm.startPrank(carly.addr);
        _dealERC20(usdc, carly.addr, TOKEN_AMOUNT);
        IERC20(usdc).approve(negRiskAdapter, TOKEN_AMOUNT);
        INegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, TOKEN_AMOUNT);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        // deal USDC to alice
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);
        // transfer yes tokens to brian
        INegRiskAdapter(negRiskAdapter).safeTransferFrom(carly.addr, brian.addr, yesPositionId, TOKEN_AMOUNT, "");
        vm.stopPrank();

        // sign alice order
        ICTFExchange.Order memory aliceOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: USDC_AMOUNT,
            _takerAmount: TOKEN_AMOUNT,
            _side: Side.BUY
        });

        // sign brian order
        ICTFExchange.Order memory brianOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: brian.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: TOKEN_AMOUNT,
            _takerAmount: USDC_AMOUNT,
            _side: Side.SELL
        });

        // takerOrder + takerFillAmount
        ICTFExchange.Order memory takerOrder = brianOrder;
        uint256 takerFillAmount = TOKEN_AMOUNT;

        // makerOrders + makerFillAmounts
        ICTFExchange.Order[] memory makerOrders = new ICTFExchange.Order[](1);
        makerOrders[0] = aliceOrder;
        uint256[] memory makerFillAmounts = new uint256[](1);
        makerFillAmounts[0] = USDC_AMOUNT;

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(brian.addr), 0);

        // -- MATCH ORDERS --
        vm.prank(operator.addr);
        IFeeModule(negRiskFeeModule).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts, 0);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }

    function test_NegRiskFeeModule_matchOrders_buyBuy() public {
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // alice approvals
        vm.startPrank(alice.addr);
        IERC20(usdc).approve(negRiskCtfExchange, USDC_AMOUNT);
        vm.stopPrank();

        // brian approvals
        vm.startPrank(brian.addr);
        IERC20(usdc).approve(negRiskCtfExchange, USDC_AMOUNT);
        vm.stopPrank();

        // usdc distribution
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);
        _dealERC20(usdc, brian.addr, USDC_AMOUNT);

        ICTFExchange.Order memory aliceOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: USDC_AMOUNT,
            _takerAmount: TOKEN_AMOUNT,
            _side: Side.BUY
        });

        ICTFExchange.Order memory brianOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: brian.privateKey,
            _tokenId: noPositionId,
            _makerAmount: USDC_AMOUNT,
            _takerAmount: TOKEN_AMOUNT,
            _side: Side.BUY
        });

        ICTFExchange.Order memory takerOrder = aliceOrder;
        uint256 takerFillAmount = USDC_AMOUNT;

        ICTFExchange.Order[] memory makerOrders = new ICTFExchange.Order[](1);
        makerOrders[0] = brianOrder;
        uint256[] memory makerFillAmounts = new uint256[](1);
        makerFillAmounts[0] = USDC_AMOUNT;

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);

        // -- MATCH ORDERS --
        vm.prank(operator.addr);
        IFeeModule(negRiskFeeModule).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts, 0);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), 0);
    }

    function test_NegRiskFeeModule_matchOrders_sellSell() public {
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // alice approvals
        vm.startPrank(alice.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // brian approvals
        vm.startPrank(brian.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // split initial tokens
        vm.startPrank(carly.addr);
        _dealERC20(usdc, carly.addr, TOKEN_AMOUNT);
        IERC20(usdc).approve(negRiskAdapter, TOKEN_AMOUNT);
        INegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, TOKEN_AMOUNT);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        // transfer yes tokens to alice
        INegRiskAdapter(negRiskAdapter).safeTransferFrom(carly.addr, alice.addr, yesPositionId, TOKEN_AMOUNT, "");
        // transfer no tokens to brian
        INegRiskAdapter(negRiskAdapter).safeTransferFrom(carly.addr, brian.addr, noPositionId, TOKEN_AMOUNT, "");
        vm.stopPrank();

        // sign alice order
        ICTFExchange.Order memory aliceOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: TOKEN_AMOUNT,
            _takerAmount: USDC_AMOUNT,
            _side: Side.SELL
        });

        // sign brian order
        ICTFExchange.Order memory brianOrder = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: brian.privateKey,
            _tokenId: noPositionId,
            _makerAmount: TOKEN_AMOUNT,
            _takerAmount: USDC_AMOUNT,
            _side: Side.SELL
        });

        // takerOrder + takerFillAmount
        ICTFExchange.Order memory takerOrder = aliceOrder;
        uint256 takerFillAmount = TOKEN_AMOUNT;

        // makerOrders + makerFillAmounts
        ICTFExchange.Order[] memory makerOrders = new ICTFExchange.Order[](1);
        makerOrders[0] = brianOrder;
        uint256[] memory makerFillAmounts = new uint256[](1);
        makerFillAmounts[0] = TOKEN_AMOUNT;

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), 0);

        // -- MATCH ORDERS --
        vm.prank(operator.addr);
        IFeeModule(negRiskFeeModule).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts, 0);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }
}
