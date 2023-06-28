// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

struct RequestSettings {
    bool eventBased; // True if the request is set to be event-based.
    bool refundOnDispute; // True if the requester should be refunded their reward on dispute.
    bool callbackOnPriceProposed; // True if callbackOnPriceProposed callback is required.
    bool callbackOnPriceDisputed; // True if callbackOnPriceDisputed callback is required.
    bool callbackOnPriceSettled; // True if callbackOnPriceSettled callback is required.
    uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
    uint256 customLiveness; // Custom liveness value set by the requester.
}

// Struct representing a price request.
struct Request {
    address proposer; // Address of the proposer.
    address disputer; // Address of the disputer.
    address currency; // ERC20 token used to pay rewards and fees.
    bool settled; // True if the request is settled.
    RequestSettings requestSettings; // Custom settings associated with a request.
    int256 proposedPrice; // Price that the proposer submitted.
    int256 resolvedPrice; // Price resolved once the request is settled.
    uint256 expirationTime; // Time at which the request auto-settles without a dispute.
    uint256 reward; // Amount of the currency to pay to the proposer on settlement.
    uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
}

contract OptimisticOracleV2 {
    int256 public price;

    // options are 0, .5 ether, 1 ether
    function setPrice(int256 _price) external {
        if (price == 0 || price == 0.5 ether || price == 1 ether) {
            price = _price;
        } else {
            revert("invalid price");
        }
    }

    function unsetPrice() external {
        price = -1;
    }

    function settleAndGetPrice(bytes32 identifier, uint256 timestamp, bytes memory ancillaryData)
        external
        view
        returns (int256)
    {
        return price;
    }

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external view returns (bool) {
        return (price == 0 || price == 0.5 ether || price == 1 ether);
    }

    function requestPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        address currency,
        uint256 reward
    ) external returns (uint256 totalBond) {
        return 0;
    }

    function setBond(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 bond
    ) external returns (uint256 totalBond) {
        return 0;
    }

    fallback() external {}
}
