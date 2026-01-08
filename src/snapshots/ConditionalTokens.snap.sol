// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "src/dev/TestHelper.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";

contract NegRiskAdapterSnapshots is TestHelper {
    USDC usdc;
    IConditionalTokens ctf;
    address oracle;

    function setUp() public {
        oracle = vm.createWallet("oracle").addr;
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
    }

    function test_snap_prepareCondition() public {
        bytes32 questionId = keccak256("questionId");

        vm.startSnapshotGas("ConditionalTokens_prepareCondition");
        ctf.prepareCondition(oracle, questionId, 2);
        vm.stopSnapshotGas();
    }

    function test_snap_reportPayouts() public {
        bytes32 questionId = keccak256("questionId");
        ctf.prepareCondition(oracle, questionId, 2);

        uint256[] memory payouts = new uint256[](2);
        payouts[0] = 1;

        vm.startPrank(oracle);
        vm.startSnapshotGas("ConditionalTokens_reportPayouts");
        ctf.reportPayouts(questionId, payouts);
        vm.stopSnapshotGas();
    }

    function test_snap_splitPosition() public {
        bytes32 questionId = keccak256("questionId");
        bytes32 conditionId = CTHelpers.getConditionId(oracle, questionId, 2);

        ctf.prepareCondition(oracle, questionId, 2);

        uint256 amount = 10_000_000;
        vm.startPrank(alice);
        usdc.mint(alice, 2 * amount);
        usdc.approve(address(ctf), 2 * amount);
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.startSnapshotGas("ConditionalTokens_splitPosition");
        ctf.splitPosition(address(usdc), bytes32(0), conditionId, partition, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_mergePositions() public {
        bytes32 questionId = keccak256("questionId");
        bytes32 conditionId = CTHelpers.getConditionId(oracle, questionId, 2);
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        ctf.prepareCondition(oracle, questionId, 2);

        uint256 amount = 10_000_000;
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.startPrank(alice);
        usdc.mint(alice, 2 * amount);
        usdc.approve(address(ctf), 3 * amount);
        ctf.splitPosition(address(usdc), bytes32(0), conditionId, partition, 2 * amount);

        vm.startSnapshotGas("ConditionalTokens_mergePositions");
        ctf.mergePositions(address(usdc), bytes32(0), conditionId, partition, amount);
        vm.stopSnapshotGas();
    }
}
