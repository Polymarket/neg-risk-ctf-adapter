// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {vm} from "../dev/libraries/Vm.sol";
import {AddressLib} from "../dev/libraries/AddressLib.sol";

import {Adapter} from "../Adapter.sol";

contract add_admin {
    function run(address _newAdmin) external {
        Adapter adapter = Adapter(AddressLib.getAddress("adapter"));

        vm.startBroadcast();

        adapter.addAdmin(_newAdmin);
    }
}
