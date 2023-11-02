// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import {Script} from "../../lib/forge-std/src/Script.sol";
import {stdStorage, StdStorage} from "../../lib/forge-std/src/StdStorage.sol";
import {vm} from "../dev/libraries/Vm.sol";

using stdStorage for StdStorage;

contract Storage is Script {
    function getStorageSlot(address _target, string memory _sig, address _param) public returns (uint256) {
        return stdstore.target(_target).sig(_sig).with_key(_param).find();
    }

    function _setERC1155Balance(address _erc1155, address _account, uint256 _id, uint256 _amount) internal {
        stdstore.target(_erc1155).sig("balanceOf(address,uint256)").with_key(_account).with_key(_id).checked_write(
            _amount
        );
    }
}
