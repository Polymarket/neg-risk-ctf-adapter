// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {IFinder} from "src/interfaces/IFinder.sol";

contract Finder is IFinder {
    address public immutable optimisticOracleV2;
    address public immutable collateralWhitelist;

    constructor(address _optimisticOracleV2, address _collateralWhitelist) {
        optimisticOracleV2 = _optimisticOracleV2;
        collateralWhitelist = _collateralWhitelist;
    }

    function changeImplementationAddress(bytes32, address) external {}

    function getImplementationAddress(bytes32 interfaceName) external view returns (address) {
        if (interfaceName == "OptimisticOracleV2") {
            return optimisticOracleV2;
        } else if (interfaceName == "CollateralWhitelist") {
            return collateralWhitelist;
        } else {
            revert();
        }
    }
}
