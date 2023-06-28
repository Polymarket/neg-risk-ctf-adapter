// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../../dev/TestHelper.sol";

import {Auth} from "../../modules/Auth.sol";
import {IAuthEE} from "../../modules/interfaces/IAuth.sol";

contract AuthHarness is Auth {
    function useOnlyAdmin() public onlyAdmin {}
}

contract AuthTest is TestHelper, IAuthEE {
    AuthHarness auth;

    function setUp() public {
        vm.prank(alice);
        auth = new AuthHarness{salt: keccak256(bytes("auth"))}();
    }

    function test_InitialAdmin() public {
        assertTrue(auth.isAdmin(alice));
        assertEq(auth.admins(alice), 1);
    }

    function test_NotAdmin() public {
        assertFalse(auth.isAdmin(brian));
        assertEq(auth.admins(brian), 0);
    }

    function test_OnlyAdmin() public {
        vm.prank(alice);
        auth.useOnlyAdmin();
    }

    function test_revert_OnlyAdmin() public {
        vm.expectRevert(NotAdmin.selector);
        auth.useOnlyAdmin();
    }

    function test_AddAdmin() public {
        vm.expectEmit();
        emit NewAdmin(alice, brian);

        vm.prank(alice);
        auth.addAdmin(brian);

        vm.prank(brian);
        auth.useOnlyAdmin();

        assertTrue(auth.isAdmin(brian));
        assertEq(auth.admins(brian), 1);
    }

    function test_revert_AddAdmin() public {
        vm.prank(brian);
        vm.expectRevert(NotAdmin.selector);
        auth.addAdmin(brian);
    }

    function test_RemoveAdmin() public {
        vm.prank(alice);
        auth.addAdmin(brian);

        vm.prank(brian);
        auth.removeAdmin(alice);

        assertFalse(auth.isAdmin(alice));
        assertEq(auth.admins(alice), 0);
    }

    function test_RenounceAdmin() public {
        vm.expectEmit();
        emit RemovedAdmin(alice, alice);

        vm.prank(alice);
        auth.renounceAdmin();

        assertFalse(auth.isAdmin(alice));
        assertEq(auth.admins(alice), 0);
    }
}
