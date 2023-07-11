// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {vm} from "src/dev/libraries/Vm.sol";
import {IAuth} from "src/modules/interfaces/IAuth.sol";

contract add_admin {
    function run(address _target, address _newAdmin) external {
        IAuth target = IAuth(_target);

        vm.broadcast();
        target.addAdmin(_newAdmin);
    }
}
