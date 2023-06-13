// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {vm} from "./Vm.sol";

library DeployLib {
    function _deployCode(string memory _what) internal returns (address addr) {
        return _deployCode(_what, "");
    }

    function _deployCode(string memory _what, bytes memory _args) internal returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(_what), _args);
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }

    function deployConditionalTokens() public returns (address) {
        address deployment = _deployCode("artifacts/ConditionalTokens.json");
        vm.label(deployment, "ConditionalTokens");
        return deployment;
    }
}
