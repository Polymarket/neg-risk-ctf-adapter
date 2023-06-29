// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

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

    function settleAndGetPrice(bytes32, uint256, bytes memory) external view returns (int256) {
        return price;
    }

    function hasPrice(address, bytes32, uint256, bytes memory) external view returns (bool) {
        return (price == 0 || price == 0.5 ether || price == 1 ether);
    }

    function requestPrice(bytes32, uint256, bytes memory, address, uint256)
        external
        pure
        returns (uint256 totalBond)
    {
        return 0;
    }

    function setBond(bytes32, uint256, bytes memory, uint256)
        external
        pure
        returns (uint256 totalBond)
    {
        return 0;
    }

    fallback() external {}
}
