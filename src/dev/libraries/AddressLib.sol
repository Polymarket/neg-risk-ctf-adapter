// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {vm} from "./Vm.sol";
import {stdJson} from "forge-std/Test.sol";

library AddressLib {
    using stdJson for string;

    function getAddress(string memory _name) internal view returns (address) {
        string memory json = vm.readFile("./addresses.json");

        uint256 chainId = block.chainid;
        string memory pathPrefix = string.concat(".", vm.toString(chainId), ".");
        string memory path = string.concat(pathPrefix, _name);

        return json.readAddress(path);
    }
}
