// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console, NegRiskAdapter_SetUp} from "./NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "../../libraries/NegRiskIdLib.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";
import {Storage} from "../../dev/Storage.sol";

/// @title NegRiskAdapter_ERC1155Operations_Test
/// @notice test the ERC1155 proxy operations of the NegRiskAdapter
///         - safeTransferFrom
///         - safeBatchTransferFrom
///         - balanceOf
///         - balanceOfBatch
contract NegRiskAdapter_ERC1155Operations_Test is NegRiskAdapter_SetUp, Storage {
    function setUp() public override {
        super.setUp();

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);
    }

    function test_ERC1155Operations_safeTransferFrom(uint256 _id, uint256 _value) public {
        _setERC1155Balance(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);

        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");

        assertEq(ctf.balanceOf(brian, _id), _value);
        assertEq(nrAdapter.balanceOf(brian, _id), _value);
    }

    function test_ERC1155Operations_safeBatchTransferFrom(uint256[] memory _ids, uint256[] memory _values) public {
        uint256 l = _ids.length & _values.length; // less than or equal to both lengths

        assembly {
            mstore(_ids, l)
            mstore(_values, l)
        }

        address[] memory accounts = new address[](l);
        for (uint256 i = 0; i < l; i++) {
            // ids without collisions
            uint256 id = uint256(keccak256(abi.encode(_ids[i], i)));
            // for checking batchBalanceOf
            accounts[i] = brian;
            _setERC1155Balance(address(ctf), alice, id, _values[i]);
            assertEq(ctf.balanceOf(alice, id), _values[i]);
            _ids[i] = id;
        }

        vm.prank(alice);
        nrAdapter.safeBatchTransferFrom(alice, brian, _ids, _values, "");

        for (uint256 i = 0; i < l; i++) {
            assertEq(ctf.balanceOf(brian, _ids[i]), _values[i]);
            assertEq(nrAdapter.balanceOf(brian, _ids[i]), _values[i]);
        }

        // balanceOfBatch
        assertEq(nrAdapter.balanceOfBatch(accounts, _ids), _values);
    }
}
