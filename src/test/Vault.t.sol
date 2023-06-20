// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TestHelper, console} from "src/dev/TestHelper.sol";
import {Vault} from "src/Vault.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";
import {Helpers} from "src/libraries/Helpers.sol";
import {IERC20} from "src/interfaces/IERC20.sol";

contract VaultTest is TestHelper {
    Vault vault;
    USDC usdc;
    IConditionalTokens ctf;

    function setUp() public {
        vm.prank(alice);
        vault = new Vault();
        usdc = new USDC();

        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
    }

    function test_admin() public {
        assertTrue(vault.isAdmin(alice));
        assertEq(vault.admins(alice), 1);

        assertFalse(vault.isAdmin(brian));
        assertEq(vault.admins(brian), 0);
    }

    function test_transferERC20(uint64 _a, uint64 _b, uint64 _c) public {
        uint256 s = uint256(_a);
        uint256 m = s + uint256(_b);
        uint256 l = m + uint256(_c);

        usdc.mint(brian, l);

        vm.prank(brian);
        usdc.transfer(address(vault), m);

        vm.prank(alice);
        vault.transferERC20(address(usdc), devin, s);

        assertEq(usdc.balanceOf(devin), s);
        assertEq(usdc.balanceOf(address(vault)), m - s);
        assertEq(usdc.balanceOf(brian), l - m);
    }

    function test_transferConditionalTokens(
        uint64 _a,
        uint64 _b,
        uint64 _c,
        bytes32 _questionId
    ) public {
        uint256 s = uint256(_a);
        uint256 m = s + uint256(_b);
        uint256 l = m + uint256(_c);

        ctf.prepareCondition(address(0), _questionId, 2);
        bytes32 conditionId = CTHelpers.getConditionId(
            address(0),
            _questionId,
            2
        );
        usdc.mint(brian, l);

        vm.startPrank(brian);
        usdc.approve(address(ctf), m);
        ctf.splitPosition(
            IERC20(address(usdc)),
            bytes32(0),
            conditionId,
            Helpers._partition(),
            m
        );

        vm.stopPrank();

        bytes32 collectionId0 = CTHelpers.getCollectionId(
            bytes32(0),
            conditionId,
            1
        );
        bytes32 collectionId1 = CTHelpers.getCollectionId(
            bytes32(0),
            conditionId,
            2
        );

        uint256 positionId0 = CTHelpers.getPositionId(
            address(usdc),
            collectionId0
        );

        uint256 positionId1 = CTHelpers.getPositionId(
            address(usdc),
            collectionId1
        );

        vm.prank(brian);
        ctf.safeTransferFrom(brian, address(vault), positionId0, m, "");
        vm.prank(brian);
        ctf.safeTransferFrom(brian, address(vault), positionId1, m, "");

        vm.prank(alice);
        vault.transferERC1155(address(ctf), carly, positionId0, s);

        vm.prank(alice);
        vault.transferERC1155(address(ctf), devin, positionId1, s);

        assertEq(ctf.balanceOf(address(vault), positionId0), m - s);
        assertEq(ctf.balanceOf(carly, positionId0), s);
        assertEq(ctf.balanceOf(address(vault), positionId1), m - s);
        assertEq(ctf.balanceOf(devin, positionId1), s);
    }
}
