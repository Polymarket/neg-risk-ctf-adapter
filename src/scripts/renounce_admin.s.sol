// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {vm} from "../dev/libraries/Vm.sol";
import {IAuth} from "../interfaces/IAuth.sol";

contract renounce_admin {
    function run(address _target) external {
        IAuth target = IAuth(_target);

        vm.broadcast();
        target.renounceAdmin();
    }
}
