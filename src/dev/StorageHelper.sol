// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {stdStorage, StdStorage} from "../../lib/forge-std/src/StdStorage.sol";
import {vm} from "./libraries/Vm.sol";

using stdStorage for StdStorage;

contract StorageHelper is Script {
    function getStorageSlot(address _target, string memory _sig, address _param) public returns (uint256) {
        return stdstore.target(_target).sig(_sig).with_key(_param).find();
    }

    function _dealERC1155(address _erc1155, address _account, uint256 _id, uint256 _amount) internal {
        stdstore.target(_erc1155).sig("balanceOf(address,uint256)").with_key(_account).with_key(_id).checked_write(
            _amount
        );
    }

    function _dealERC20(address _erc20, address _account, uint256 _amount) internal {
        uint256 storageSlot = getStorageSlot(_erc20, "balanceOf(address)", address(_account));
        vm.store(_erc20, bytes32(storageSlot), bytes32(_amount));
    }

    function _setOperator(address _exchange, address _operator) internal {
        uint256 storageSlot = getStorageSlot(_exchange, "operators(address)", _operator);
        vm.store(_exchange, bytes32(storageSlot), bytes32(uint256(1)));
    }

    function _setAdmin(address _exchange, address _admin) internal {
        uint256 storageSlot = getStorageSlot(_exchange, "admins(address)", _admin);
        vm.store(_exchange, bytes32(storageSlot), bytes32(uint256(1)));
    }
}
