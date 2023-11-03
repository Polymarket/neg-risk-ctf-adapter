// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console, NegRiskAdapter_SetUp} from "./NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "../../libraries/NegRiskIdLib.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";
import {StorageHelper} from "../../dev/StorageHelper.sol";

/// @title NegRiskAdapter_ERC1155Operations_Test
/// @notice test the ERC1155 proxy operations of the NegRiskAdapter
///         - safeTransferFrom
///         - safeBatchTransferFrom
///         - balanceOf
///         - balanceOfBatch
contract NegRiskAdapter_ERC1155Operations_Test is NegRiskAdapter_SetUp, StorageHelper {
    function setUp() public override {
        super.setUp();
    }

    function test_ERC1155Operations_safeTransferFrom(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

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
            _dealERC1155(address(ctf), alice, id, _values[i]);
            assertEq(ctf.balanceOf(alice, id), _values[i]);
            _ids[i] = id;
        }

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.prank(alice);
        nrAdapter.safeBatchTransferFrom(alice, brian, _ids, _values, "");

        for (uint256 i = 0; i < l; i++) {
            assertEq(ctf.balanceOf(brian, _ids[i]), _values[i]);
            assertEq(nrAdapter.balanceOf(brian, _ids[i]), _values[i]);
        }

        // balanceOfBatch
        assertEq(nrAdapter.balanceOfBatch(accounts, _ids), _values);
    }

    function test_ERC1155Operations_authorizedSafeTransferFrom(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);

        // need two approvals
        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.prank(alice);
        ctf.setApprovalForAll(brian, true);

        vm.prank(brian);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");

        assertEq(ctf.balanceOf(brian, _id), _value);
    }

    function test_ERC1155Operations_authorizedSafeBatchTransferFrom(uint256 _id, uint256 _value) public {
        uint256[] memory ids = new uint256[](8);
        uint256[] memory values = new uint256[](8);

        for (uint256 i = 0; i < 8; i++) {
            ids[i] = uint256(keccak256(abi.encode("id", i)));
            values[i] = uint256(keccak256(abi.encode("value", i)));
            _dealERC1155(address(ctf), alice, ids[i], values[i]);
        }

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.prank(alice);
        ctf.setApprovalForAll(brian, true);

        vm.prank(brian);
        nrAdapter.safeBatchTransferFrom(alice, brian, ids, values, "");

        for (uint256 i = 0; i < 8; i++) {
            assertEq(ctf.balanceOf(brian, ids[i]), values[i]);
        }
    }

    function test_revert_ERC1155Operations_unauthorizedSafeTransferFrom(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.expectRevert(NotApprovedForAll.selector);
        vm.prank(brian);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");
    }

    function test_revert_ERC1155Operations_unauthorizedSafeBatchTransferFrom() public {
        uint256[] memory ids = new uint256[](8);
        uint256[] memory values = new uint256[](8);

        for (uint256 i = 0; i < 8; i++) {
            ids[i] = uint256(keccak256(abi.encode("id", i)));
            values[i] = uint256(keccak256(abi.encode("value", i)));
            _dealERC1155(address(ctf), alice, ids[i], values[i]);
        }

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.expectRevert(NotApprovedForAll.selector);
        vm.prank(brian);
        nrAdapter.safeBatchTransferFrom(alice, brian, ids, values, "");
    }
}
