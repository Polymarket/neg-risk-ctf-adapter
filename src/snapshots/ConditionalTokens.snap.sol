// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {TestHelper} from "src/dev/TestHelper.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";

contract ConditionalTokensSnapshots is TestHelper, GasSnapshot {
    USDC usdc;
    IConditionalTokens ctf;
    address oracle;

    function setUp() public {
        oracle = _getAndLabelAddress("oracle");
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
    }

    function test_snap_prepareCondition() public {
        bytes32 questionId = keccak256("questionId");

        snapStart("ConditionalTokens_prepareCondition");
        ctf.prepareCondition(oracle, questionId, 2);
        snapEnd();
    }

    function test_snap_reportPayouts() public {
        bytes32 questionId = keccak256("questionId");
        ctf.prepareCondition(oracle, questionId, 2);

        uint256[] memory payouts = new uint256[](2);
        payouts[0] = 1;

        vm.startPrank(oracle);
        snapStart("ConditionalTokens_reportPayouts");
        ctf.reportPayouts(questionId, payouts);
        snapEnd();
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

        snapStart("ConditionalTokens_splitPosition");
        ctf.splitPosition(address(usdc), bytes32(0), conditionId, partition, amount);
        snapEnd();
    }

    function test_snap_mergePositions() public {
        bytes32 questionId = keccak256("questionId");
        bytes32 conditionId = CTHelpers.getConditionId(oracle, questionId, 2);
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        ctf.prepareCondition(oracle, questionId, 2);

        uint256 amount = 10_000_000;

        vm.startPrank(alice);
        usdc.mint(alice, 2 * amount);
        usdc.approve(address(ctf), 3 * amount);
        ctf.splitPosition(address(usdc), bytes32(0), conditionId, partition, 2 * amount);

        snapStart("ConditionalTokens_mergePositions");
        ctf.mergePositions(address(usdc), bytes32(0), conditionId, partition, amount);
        snapEnd();
    }
}
