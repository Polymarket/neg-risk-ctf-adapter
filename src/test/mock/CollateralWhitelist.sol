// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IAddressWhitelist} from "src/interfaces/IAddressWhitelist.sol";

contract CollateralWhitelist is IAddressWhitelist {
    function addToWhitelist(address) external {}

    function removeFromWhitelist(address) external {}

    function isOnWhitelist(address) external pure returns (bool) {
        return true;
    }

    function getWhitelist() external pure returns (address[] memory) {
        return new address[](0);
    }
}
