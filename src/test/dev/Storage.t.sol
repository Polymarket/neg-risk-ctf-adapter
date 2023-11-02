// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "../../dev/TestHelper.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {Storage} from "../../dev/Storage.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";

contract Storage_Test is TestHelper, Storage {
    function test_Storage_ERC1155Balances(uint256 _id, uint256 _amount) public {
        address alice = vm.createWallet("alice").addr;
        address ctf = DeployLib.deployConditionalTokens();
        _setERC1155Balance(ctf, alice, _id, _amount);

        assertEq(IConditionalTokens(ctf).balanceOf(alice, _id), _amount);
    }
}
