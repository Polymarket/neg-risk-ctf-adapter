// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {stdStorage, StdStorage} from "../../lib/forge-std/src/StdStorage.sol";
import {Side, SignatureType} from "../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";

import {vm} from "./libraries/Vm.sol";
import {ICTFExchange} from "../interfaces/index.sol";

using stdStorage for StdStorage;

contract OrderHelper is Script {
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
