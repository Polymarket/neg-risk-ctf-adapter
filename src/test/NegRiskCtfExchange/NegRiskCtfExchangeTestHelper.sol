// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Test, Vm} from "../../../lib/forge-std/src/Test.sol";
import {Side, SignatureType} from "../../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";
import {NegRiskAdapter} from "../../NegRiskAdapter.sol";
import {IConditionalTokens, ICTFExchange, IERC20} from "../../interfaces/index.sol";
import {AddressLib} from "../../dev/libraries/AddressLib.sol";
import {Storage} from "../../dev/Storage.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {USDC} from "../mock/USDC.sol";

contract NegRiskCtfExchangeTestHelper is Test, Storage {
    address immutable ctf;
    address immutable negRiskAdapter;
    address immutable negRiskCtfExchange;
    address immutable usdc;

    Vm.Wallet alice;
    Vm.Wallet brian;
    Vm.Wallet carly;
    Vm.Wallet admin;
    Vm.Wallet operator;

    uint256[] partition;

    bytes32 marketId;
    bytes32 questionId;
    bytes32 conditionId;

    uint256 yesPositionId;
    uint256 noPositionId;

    constructor() {
        admin = vm.createWallet("admin");
        operator = vm.createWallet("operator");

        alice = vm.createWallet("alice");
        brian = vm.createWallet("brian");
        carly = vm.createWallet("carly");

        address vault = vm.createWallet("vault").addr;

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

        partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        _setAdmin(negRiskCtfExchange, admin.addr);
        _setOperator(negRiskCtfExchange, operator.addr);

        ICTFExchange(negRiskCtfExchange).renounceAdminRole();
        ICTFExchange(negRiskCtfExchange).renounceOperatorRole();
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

    function _createAndSignOrder(
        address _exchange,
        uint256 _pk,
        uint256 _tokenId,
        uint256 _makerAmount,
        uint256 _takerAmount,
        Side _side
    ) internal view returns (ICTFExchange.Order memory) {
        address maker = vm.addr(_pk);
        ICTFExchange.Order memory order = _createOrder(maker, _tokenId, _makerAmount, _takerAmount, _side);
        // ICTFExchange.Order memory order = abi.decode(abi.encode(order_), (ICTFExchange.Order));
        order.signature = _signMessage(_pk, ICTFExchange(_exchange).hashOrder(order));
        return order;
    }

    function _signMessage(uint256 _pk, bytes32 _message) internal pure returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(_pk, _message);
        return abi.encodePacked(r, s, v);
    }

    function _createOrder(address _maker, uint256 _tokenId, uint256 _makerAmount, uint256 _takerAmount, Side _side)
        internal
        pure
        returns (ICTFExchange.Order memory)
    {
        ICTFExchange.Order memory order = ICTFExchange.Order({
            salt: 1,
            signer: _maker,
            maker: _maker,
            taker: address(0),
            tokenId: _tokenId,
            makerAmount: _makerAmount,
            takerAmount: _takerAmount,
            expiration: 0,
            nonce: 0,
            feeRateBps: 0,
            signatureType: uint8(SignatureType.EOA),
            side: uint8(_side),
            signature: new bytes(0)
        });
        return order;
    }
}
