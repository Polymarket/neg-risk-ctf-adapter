// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Test, Vm} from "../../lib/forge-std/src/Test.sol";
import {
    Order,
    Side,
    MatchType,
    OrderStatus,
    SignatureType
} from "../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";
import {NegRiskAdapter} from "../NegRiskAdapter.sol";
import {IConditionalTokens, ICTFExchange, IERC20} from "../interfaces/index.sol";
import {AddressLib} from "../dev/libraries/AddressLib.sol";
import {Storage} from "../dev/Storage.sol";
import {DeployLib} from "../dev/libraries/DeployLib.sol";
import {USDC} from "./mock/USDC.sol";

contract NegRiskCtfExchange_Test is Test, Storage {
    address immutable ctf;
    address immutable negRiskAdapter;
    address immutable negRiskCtfExchange;
    address immutable usdc;

    Vm.Wallet alice;
    Vm.Wallet brian;

    constructor() {
        alice = vm.createWallet("alice");
        brian = vm.createWallet("brian");

        address vault = vm.createWallet("vault").addr;
        address oracle = vm.createWallet("oracle").addr;

        ctf = DeployLib.deployConditionalTokens();
        usdc = address(new USDC());
        negRiskAdapter = address(new NegRiskAdapter(ctf, usdc, vault));
        negRiskCtfExchange = DeployLib.deployNegRiskCtfExchange({
            _collateral: usdc,
            _ctf: ctf,
            _negRiskAdapter: negRiskAdapter,
            _proxyFactory: address(0),
            _safeFactory: address(0)
        });
    }

    function setUp() public {}

    function test_Trading_mintTestTokens() public {
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        _dealERC20(usdc, alice.addr, type(uint128).max);
        _dealERC20(usdc, brian.addr, type(uint128).max);

        // 1. first set of approvals, approve USDC to negRiskExchange

        vm.prank(alice.addr);
        IERC20(usdc).approve(negRiskCtfExchange, type(uint256).max);

        vm.prank(brian.addr);
        IERC20(usdc).approve(negRiskCtfExchange, type(uint256).max);

        vm.startPrank(alice.addr);

        bytes32 marketId = NegRiskAdapter(negRiskAdapter).prepareMarket(0, "test_market");
        bytes32 questionId = NegRiskAdapter(negRiskAdapter).prepareQuestion(marketId, "test_market");
        bytes32 conditionId = NegRiskAdapter(negRiskAdapter).getConditionId(questionId);

        IERC20(usdc).approve(negRiskAdapter, type(uint256).max);
        NegRiskAdapter(negRiskAdapter).splitPosition(usdc, bytes32(0), conditionId, partition, 1_000_000_000);

        IConditionalTokens(ctf).setApprovalForAll(negRiskCtfExchange, true);
        uint256 yesPositionId = NegRiskAdapter(negRiskAdapter).getPositionId(questionId, true);
        uint256 noPositionId = NegRiskAdapter(negRiskAdapter).getPositionId(questionId, false);

        vm.stopPrank();

        _setAdmin(negRiskCtfExchange, alice.addr);
        _setOperator(negRiskCtfExchange, alice.addr);

        vm.prank(brian.addr);
        IConditionalTokens(ctf).setApprovalForAll(negRiskAdapter, true);

        vm.startPrank(alice.addr);
        ICTFExchange(negRiskCtfExchange).registerToken(yesPositionId, noPositionId, conditionId);
        IConditionalTokens(ctf).safeTransferFrom(alice.addr, brian.addr, yesPositionId, 1_000_000_000, "");

        ICTFExchange.Order memory brianOrder = _createAndSignOrder({
            _pk: brian.privateKey,
            _tokenId: yesPositionId,
            _makerAmount: 50_000_000,
            _takerAmount: 100_000_000,
            _side: Side.SELL
        });

        ICTFExchange(negRiskCtfExchange).fillOrder(brianOrder, 25_000_000);
    }

    function _dealERC20(address _erc20, address _account, uint256 _amount) internal {
        uint256 storageSlot = getStorageSlot(_erc20, "balanceOf(address)", address(_account));
        vm.store(_erc20, bytes32(storageSlot), bytes32(_amount));
    }

    function _setOperator(address _exchange, address _operator) internal {
        uint256 storageSlot = getStorageSlot(_exchange, "operators(address)", _operator);
        vm.store(_exchange, bytes32(storageSlot), bytes32(uint256(1)));
    }

    function _setAdmin(address _exchange, address _admin) internal {
        uint256 storageSlot = getStorageSlot(_exchange, "admins(address)", _admin);
        vm.store(_exchange, bytes32(storageSlot), bytes32(uint256(1)));
    }

    function _createAndSignOrder(uint256 _pk, uint256 _tokenId, uint256 _makerAmount, uint256 _takerAmount, Side _side)
        internal
        view
        returns (ICTFExchange.Order memory)
    {
        address maker = vm.addr(_pk);
        ICTFExchange.Order memory order = _createOrder(maker, _tokenId, _makerAmount, _takerAmount, _side);
        // ICTFExchange.Order memory order = abi.decode(abi.encode(order_), (ICTFExchange.Order));
        order.signature = _signMessage(_pk, ICTFExchange(negRiskCtfExchange).hashOrder(order));
        return order;
    }

    function _signMessage(uint256 _pk, bytes32 _message) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_pk, _message);
        return abi.encodePacked(r, s, v);
    }

    function _createOrder(address maker, uint256 tokenId, uint256 makerAmount, uint256 takerAmount, Side side)
        internal
        pure
        returns (ICTFExchange.Order memory)
    {
        ICTFExchange.Order memory order = ICTFExchange.Order({
            salt: 1,
            signer: maker,
            maker: maker,
            taker: address(0),
            tokenId: tokenId,
            makerAmount: makerAmount,
            takerAmount: takerAmount,
            expiration: 0,
            nonce: 0,
            feeRateBps: 0,
            signatureType: uint8(SignatureType.EOA),
            side: uint8(side),
            signature: new bytes(0)
        });
        return order;
    }
}
