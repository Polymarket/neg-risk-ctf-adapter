// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {console, Test} from "../../../lib/forge-std/src/Test.sol";
import {Side} from "../../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";
import {IConditionalTokens, ICTFExchange, IERC20, INegRiskAdapter} from "../../interfaces/index.sol";
import {AddressLib} from "../../dev/libraries/AddressLib.sol";
import {NegRiskCtfExchangeTestHelper} from "./NegRiskCtfExchangeTestHelper.sol";

contract NegRiskCtfExchange_Test is NegRiskCtfExchangeTestHelper {
    function setUp() public {
        marketId = INegRiskAdapter(negRiskAdapter).prepareMarket(0, "test_market");
        questionId = INegRiskAdapter(negRiskAdapter).prepareQuestion(marketId, "test_market");
        conditionId = INegRiskAdapter(negRiskAdapter).getConditionId(questionId);

        yesPositionId = INegRiskAdapter(negRiskAdapter).getPositionId(questionId, true);
        noPositionId = INegRiskAdapter(negRiskAdapter).getPositionId(questionId, false);

        vm.prank(admin.addr);
        ICTFExchange(negRiskCtfExchange).registerToken(yesPositionId, noPositionId, conditionId);
    }

    function test_NegRiskCtfExchange_fillOrderBuy() public {
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // operator approvals
        vm.startPrank(operator.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // alice approvals
        vm.prank(alice.addr);
        IERC20(usdc).approve(negRiskCtfExchange, USDC_AMOUNT);

        // split initial tokens
        vm.startPrank(carly.addr);
        _dealERC20(usdc, carly.addr, TOKEN_AMOUNT);
        IERC20(usdc).approve(negRiskAdapter, TOKEN_AMOUNT);
        INegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, TOKEN_AMOUNT);
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, operator.addr, yesPositionId, TOKEN_AMOUNT, "");
        vm.stopPrank();

        // deal alice USDC
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);

        // sign order
        ICTFExchange.Order memory order = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: USDC_AMOUNT,
            _takerAmount: TOKEN_AMOUNT,
            _side: Side.BUY
        });

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(operator.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(operator.addr), 0);

        // -- FILL ORDER
        vm.prank(operator.addr);
        ICTFExchange(negRiskCtfExchange).fillOrder(order, USDC_AMOUNT);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(operator.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(operator.addr), USDC_AMOUNT);
    }

    function test_NegRiskCtfExchange_fillOrderSell() public {
        uint256 USDC_AMOUNT = 50_000_000;
        uint256 TOKEN_AMOUNT = 100_000_000;

        // operator approvals
        vm.startPrank(operator.addr);
        IERC20(usdc).approve(negRiskCtfExchange, USDC_AMOUNT);
        vm.stopPrank();

        // alice approvals
        vm.startPrank(alice.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);
        vm.stopPrank();

        // split initial tokens
        vm.startPrank(carly.addr);
        _dealERC20(usdc, carly.addr, TOKEN_AMOUNT);
        IERC20(usdc).approve(negRiskAdapter, TOKEN_AMOUNT);
        INegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, TOKEN_AMOUNT);
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, alice.addr, yesPositionId, TOKEN_AMOUNT, "");
        vm.stopPrank();

        // deal operator USDC
        _dealERC20(usdc, operator.addr, USDC_AMOUNT);

        // sign order
        ICTFExchange.Order memory order = _createAndSignOrder({
            _exchange: negRiskCtfExchange,
            _pk: alice.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: TOKEN_AMOUNT,
            _takerAmount: USDC_AMOUNT,
            _side: Side.SELL
        });

        // before
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(operator.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(operator.addr), USDC_AMOUNT);

        // -- FILL ORDER
        vm.prank(operator.addr);
        ICTFExchange(negRiskCtfExchange).fillOrder(order, TOKEN_AMOUNT);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(operator.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(operator.addr), 0);
    }

    function test_NegRiskCtfExchange_matchOrders_buySell() public {
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
        // transfer yes tokens to brian
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, brian.addr, yesPositionId, TOKEN_AMOUNT, "");
        // deal USDC to alice
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);
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
        ICTFExchange(negRiskCtfExchange).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }

    function test_NegRiskCtfExchange_matchOrders_sellBuy() public {
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
        // transfer yes tokens to brian
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, brian.addr, yesPositionId, TOKEN_AMOUNT, "");
        // deal USDC to alice
        _dealERC20(usdc, alice.addr, USDC_AMOUNT);
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
        ICTFExchange(negRiskCtfExchange).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }

    function test_NegRiskCtfExchange_matchOrders_buyBuy() public {
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
        ICTFExchange(negRiskCtfExchange).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), TOKEN_AMOUNT);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), TOKEN_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(alice.addr), 0);
        assertEq(IERC20(usdc).balanceOf(brian.addr), 0);
    }

    function test_NegRiskCtfExchange_matchOrders_sellSell() public {
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
        // transfer yes tokens to alice
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, alice.addr, yesPositionId, TOKEN_AMOUNT, "");
        // transfer no tokens to brian
        IConditionalTokens(ctf).safeTransferFrom(carly.addr, brian.addr, noPositionId, TOKEN_AMOUNT, "");
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
        ICTFExchange(negRiskCtfExchange).matchOrders(takerOrder, makerOrders, takerFillAmount, makerFillAmounts);

        // after
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, yesPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(alice.addr, noPositionId), 0);
        assertEq(IConditionalTokens(ctf).balanceOf(brian.addr, noPositionId), 0);
        assertEq(IERC20(usdc).balanceOf(alice.addr), USDC_AMOUNT);
        assertEq(IERC20(usdc).balanceOf(brian.addr), USDC_AMOUNT);
    }
}
