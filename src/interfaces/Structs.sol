// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

struct Order {
    uint256 salt;
    address maker;
    address signer;
    address taker;
    uint256 tokenId;
    uint256 makerAmount;
    uint256 takerAmount;
    uint256 expiration;
    uint256 nonce;
    uint256 feeRateBps;
    uint8 side;
    uint8 signatureType;
    bytes signature;
}
