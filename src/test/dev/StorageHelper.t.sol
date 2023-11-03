// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console, Test} from "../../../lib/forge-std/src/Test.sol";
import {StorageHelper} from "../../dev/StorageHelper.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";

contract StorageHelper_Test is Test, StorageHelper {
    function test_Storage_ERC1155Balances(uint256 _id, uint256 _amount) public {
        address alice = vm.createWallet("alice").addr;
        address ctf = DeployLib.deployConditionalTokens();
        _dealERC1155(ctf, alice, _id, _amount);

        assertEq(IConditionalTokens(ctf).balanceOf(alice, _id), _amount);
    }
}
