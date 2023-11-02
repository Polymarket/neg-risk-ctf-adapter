// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console2 as console, stdJson, stdStorage, StdStorage, stdError} from "lib/forge-std/src/Test.sol";

abstract contract TestHelper is Test {
    using stdJson for string;

    address public alice;
    address public brian;
    address public carly;
    address public devin;

    constructor() {
        alice = vm.createWallet("alice").addr;
        brian = vm.createWallet("brian").addr;
        carly = vm.createWallet("carly").addr;
        devin = vm.createWallet("devin").addr;
    }
}
