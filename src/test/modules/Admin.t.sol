// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../../dev/TestHelper.sol";

import {Admin} from "../../modules/Admin.sol";
import {IAdminEE} from "../../modules/interfaces/IAdmin.sol";

uint256 constant SAFETY_PERIOD = 1 hours;

contract AdminHarness is Admin {
    constructor() Admin(SAFETY_PERIOD) {}

    function useOnlyIfUnpaused(bytes32 _questionId) public onlyIfUnpaused(_questionId) {}

    function useOnlyIfEmergencyResolutionIsAllowed(bytes32 _questionId)
        public
        onlyIfEmergencyResolutionIsAllowed(_questionId)
    {}

    function isPaused(bytes32 _questionId) public view returns (bool) {
        return _isPaused(_questionId);
    }
}

contract AdminTest is TestHelper, IAdminEE {
    AdminHarness admin;

    address adminAccount;

    function setUp() public {
        uint256 adminAccountPk = uint256(bytes32(keccak256(bytes("admin"))));
        adminAccount = vm.rememberKey(adminAccountPk);
        vm.deal(adminAccount, 1000);

        vm.prank(adminAccount);
        admin = new AdminHarness();
    }

    function test_InitialState(bytes32 _questionId) public {
        assertTrue(admin.isAdmin(adminAccount));
        assertEq(admin.emergencyResolutionTimestamps(_questionId), 0);
        assertFalse(admin.isPaused(_questionId));
    }

    function test_Pause(bytes32 _questionId) public {
        vm.expectEmit();
        emit QuestionPaused(_questionId);

        vm.prank(adminAccount);
        admin.pause(_questionId);
        assertGt(admin.emergencyResolutionTimestamps(_questionId), block.timestamp);
        assertTrue(admin.isPaused(_questionId));
    }

    function test_revert_PauseFromNonAdmin(bytes32 _questionId) public {
        vm.expectRevert(NotAdmin.selector);
        admin.pause(_questionId);
    }

    function test_revert_PauseWhenAlreadyPaused(bytes32 _questionId) public {
        vm.startPrank(adminAccount);
        admin.pause(_questionId);

        vm.expectRevert(QuestionIsPaused.selector);
        admin.pause(_questionId);
    }

    function test_PauseAndUnpause(bytes32 _questionId) public {
        vm.startPrank(adminAccount);
        admin.pause(_questionId);

        vm.expectEmit();
        emit QuestionUnpaused(_questionId);

        admin.unpause(_questionId);
        assertEq(admin.emergencyResolutionTimestamps(_questionId), 0);
        assertFalse(admin.isPaused(_questionId));
    }

    function test_revert_UnpauseWhenAlreadyUnpaused(bytes32 _questionId) public {
        vm.prank(adminAccount);
        vm.expectRevert(QuestionIsNotPaused.selector);
        admin.unpause(_questionId);
    }

    function test_revert_UnpauseNotAdmin(bytes32 _questionId) public {
        vm.expectRevert(NotAdmin.selector);
        admin.unpause(_questionId);
    }

    function test_OnlyIfUnpaused(bytes32 _questionId) public {
        admin.useOnlyIfUnpaused(_questionId);
    }

    function test_revert_OnlyIfUnpaused(bytes32 _questionId) public {
        vm.prank(adminAccount);
        admin.pause(_questionId);

        vm.expectRevert(QuestionIsPaused.selector);
        admin.useOnlyIfUnpaused(_questionId);
    }

    function test_revert_OnlyIfUnpausedGlobal(bytes32 _questionId) public {
        vm.prank(adminAccount);
        admin.pauseGlobally();

        vm.expectRevert(ContractIsGloballyPaused.selector);
        admin.useOnlyIfUnpaused(_questionId);
    }

    function test_GlobalPause(bytes32 _questionId) public {
        assertFalse(admin.isGloballyPaused());
        admin.useOnlyIfUnpaused(_questionId);

        vm.expectEmit();
        emit ContractGloballyPaused();

        vm.prank(adminAccount);
        admin.pauseGlobally();

        assertTrue(admin.isGloballyPaused());
    }

    function test_revert_GlobalPauseWhenAlreadyGloballyPaused() public {
        vm.prank(adminAccount);
        admin.pauseGlobally();

        vm.expectRevert(ContractIsGloballyPaused.selector);
        vm.prank(adminAccount);
        admin.pauseGlobally();
    }

    function test_revert_GlobalUnpauseWhenAlreadyGloballyUnpaused() public {
        vm.expectRevert(ContractIsNotGloballyPaused.selector);
        vm.prank(adminAccount);
        admin.unpauseGlobally();
    }

    function test_GlobalUnpause(bytes32 _questionId) public {
        vm.prank(adminAccount);
        admin.pauseGlobally();

        assertTrue(admin.isGloballyPaused());

        vm.prank(adminAccount);
        admin.unpauseGlobally();

        assertFalse(admin.isGloballyPaused());
        admin.useOnlyIfUnpaused(_questionId);
    }

    function test_revert_GlobalPauseNotAdmin() public {
        vm.prank(alice);
        vm.expectRevert(NotAdmin.selector);
        admin.pauseGlobally();
    }

    function test_revert_GlobalUnpauseNotAdmin() public {
        vm.prank(adminAccount);
        admin.pauseGlobally();

        vm.prank(alice);

        vm.expectRevert(NotAdmin.selector);
        admin.unpauseGlobally();
    }

    function test_UseOnlyIfEmergencyResolutionIsAllowed(
        bytes32 _questionId,
        uint32 _blockTimestamp,
        uint64 _delta
    ) public {
        vm.warp(_blockTimestamp);

        vm.prank(adminAccount);
        admin.pause(_questionId);

        uint256 emergencyResolutionTimestamp = admin.emergencyResolutionTimestamps(_questionId);
        uint256 timestamp = bound(_delta, emergencyResolutionTimestamp, type(uint64).max);

        vm.warp(timestamp);

        admin.useOnlyIfEmergencyResolutionIsAllowed(_questionId);
    }

    function test_revert_UseOnlyIfEmergencyResolutionIsAllowed(
        bytes32 _questionId,
        uint32 _blockTimestamp,
        uint64 _delta
    ) public {
        vm.warp(_blockTimestamp);

        vm.prank(adminAccount);
        admin.pause(_questionId);

        uint256 emergencyResolutionTimestamp = admin.emergencyResolutionTimestamps(_questionId);
        uint256 timestamp = bound(_delta, _blockTimestamp, emergencyResolutionTimestamp - 1);

        vm.warp(timestamp);

        vm.expectRevert(SafetyPeriodNotPassed.selector);
        admin.useOnlyIfEmergencyResolutionIsAllowed(_questionId);
    }
}
