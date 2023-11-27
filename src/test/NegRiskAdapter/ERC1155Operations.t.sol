// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console, NegRiskAdapter_SetUp} from "./NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "../../libraries/NegRiskIdLib.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";
import {StorageHelper} from "../../dev/StorageHelper.sol";

/// @title NegRiskAdapter_ERC1155Operations_Test
/// @notice test the ERC1155 proxy operations of the NegRiskAdapter
///         - safeTransferFrom
///         - balanceOf
contract NegRiskAdapter_ERC1155Operations_Test is NegRiskAdapter_SetUp, StorageHelper {
    function setUp() public override {
        super.setUp();
    }

    /*//////////////////////////////////////////////////////////////
                           SAFE TRANSFER FROM
    //////////////////////////////////////////////////////////////*/

    // only an admin can transfer, and they must additionally have approval
    function test_ERC1155Operations_safeTransferFrom(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.prank(alice);
        ctf.setApprovalForAll(admin, true);

        vm.prank(admin);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");

        assertEq(ctf.balanceOf(brian, _id), _value);
        // proxied balanceOf
        assertEq(nrAdapter.balanceOf(brian, _id), _value);
    }

    // only an admin can transfer, and they must additionally have approval
    function test_revert_ERC1155Operations_safeTransferFrom_notAdmin(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.prank(alice);
        ctf.setApprovalForAll(carly, true);

        vm.expectRevert(NotAdmin.selector);

        vm.prank(carly);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");
    }

    // only an admin can transfer, and they must additionally have approval
    function test_revert_ERC1155Operations_safeTransferFrom_missingApproval1(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.expectRevert(NotApprovedForAll.selector);

        vm.prank(admin);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");
    }

    // only an admin can transfer, and they must additionally have approval
    function test_revert_ERC1155Operations_safeTransferFrom_missingApproval2(uint256 _id, uint256 _value) public {
        _dealERC1155(address(ctf), alice, _id, _value);
        assertEq(ctf.balanceOf(alice, _id), _value);

        vm.prank(alice);
        ctf.setApprovalForAll(admin, true);

        vm.expectRevert("ERC1155: need operator approval for 3rd party transfers.");

        vm.prank(admin);
        nrAdapter.safeTransferFrom(alice, brian, _id, _value, "");
    }
}
