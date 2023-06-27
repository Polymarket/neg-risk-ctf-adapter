// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {
    Test,
    console2 as console,
    stdJson,
    stdStorage,
    StdStorage,
    stdError
} from "forge-std/Test.sol";

abstract contract TestHelper is Test {
    using stdJson for string;

    address public immutable alice;
    address public immutable brian;
    address public immutable carly;
    address public immutable devin;

    constructor() {
        alice = _getAndLabelAddress("alice");
        brian = _getAndLabelAddress("brian");
        carly = _getAndLabelAddress("carly");
        devin = _getAndLabelAddress("devin");
    }

    function _getAndLabelAddress(string memory _name) internal returns (address) {
        address addr = address(bytes20(keccak256(abi.encode(_name))));
        vm.label(addr, _name);
        return addr;
    }
}
