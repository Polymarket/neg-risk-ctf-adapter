// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {TestHelper} from "src/dev/TestHelper.sol";
import {Vault} from "src/Vault.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";
import {Helpers} from "src/libraries/Helpers.sol";

contract VaultSnapshots is TestHelper, GasSnapshot {
    USDC usdc;
    IConditionalTokens ctf;
    Vault vault;

    function setUp() public {
        vm.prank(alice);
        vault = new Vault();
        usdc = new USDC();
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
    }

    function test_snap_transferERC20() public {
        uint256 amount = 10_000_000;

        usdc.mint(brian, amount);

        vm.prank(brian);
        usdc.transfer(address(vault), amount);

        vm.startPrank(alice);

        snapStart("Vault_transferERC20");
        vault.transferERC20(address(usdc), devin, amount);
        snapEnd();
    }

    function test_snap_transferERC1155() public {
        uint256 amount = 10_000_000;
        bytes32 questionId = keccak256("questionId");

        ctf.prepareCondition(address(0), questionId, 2);
        bytes32 conditionId = CTHelpers.getConditionId(
            address(0),
            questionId,
            2
        );
        usdc.mint(brian, amount);

        vm.startPrank(brian);
        usdc.approve(address(ctf), amount);
        ctf.splitPosition(
            address(usdc),
            bytes32(0),
            conditionId,
            Helpers._partition(),
            amount
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
        ctf.safeTransferFrom(brian, address(vault), positionId0, amount, "");
        vm.prank(brian);
        ctf.safeTransferFrom(brian, address(vault), positionId1, amount, "");

        vm.startPrank(alice);
        snapStart("Vault_transferERC1155");
        vault.transferERC1155(address(ctf), carly, positionId0, amount);
        snapEnd();
    }
}
