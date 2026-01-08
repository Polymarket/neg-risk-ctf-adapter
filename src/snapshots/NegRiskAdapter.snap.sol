// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "src/dev/TestHelper.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {USDC} from "src/test/mock/USDC.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";

contract NegRiskAdapterSnapshots is TestHelper {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    function setUp() public {
        vault = vm.createWallet("vault").addr;
        oracle = vm.createWallet("oracle").addr;
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
    }

    function test_snap_prepareMarket() public {
        uint256 feeBips = 1_00;
        bytes memory data = new bytes(128);

        vm.startPrank(oracle);

        vm.startSnapshotGas("NegRiskAdapter_prepareMarket");
        nrAdapter.prepareMarket(feeBips, data);
        vm.stopSnapshotGas();
    }

    function test_snap_prepareQuestion() public {
        uint256 feeBips = 1_00;
        bytes memory data = new bytes(128);

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;

        while (i < 16) {
            nrAdapter.prepareQuestion(marketId, data);
            assertEq(nrAdapter.getQuestionCount(marketId), i + 1);
            ++i;
        }

        vm.startSnapshotGas("NegRiskAdapter_prepareQuestion");
        nrAdapter.prepareQuestion(marketId, data);
        vm.stopSnapshotGas();
    }

    function test_snap_splitPosition() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice

        vm.startPrank(alice);
        usdc.mint(alice, 3 * amount);
        usdc.approve(address(nrAdapter), 2 * amount);
        nrAdapter.splitPosition(conditionId, amount);

        // no balances should zero before _or_ after snap
        vm.startSnapshotGas("NegRiskAdapter_splitPosition");
        nrAdapter.splitPosition(conditionId, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_mergePositions() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice
        vm.startPrank(alice);
        usdc.mint(alice, 4 * amount);
        usdc.approve(address(nrAdapter), 3 * amount);
        nrAdapter.splitPosition(conditionId, 2 * amount);
        ctf.setApprovalForAll(address(nrAdapter), true);

        // no balances should zero before _or_ after snap
        vm.startSnapshotGas("NegRiskAdapter_mergePositions");
        nrAdapter.mergePositions(conditionId, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_5() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 5;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.startSnapshotGas("NegRiskAdapter_convertPositions_5");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_32() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 32;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.startSnapshotGas("NegRiskAdapter_convertPositions_32");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_64() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 64;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.startSnapshotGas("NegRiskAdapter_convertPositions_64");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_96() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 96;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);
        vm.startSnapshotGas("NegRiskAdapter_convertPositions_96");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_128() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 128;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.startSnapshotGas("NegRiskAdapter_convertPositions_128");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }

    function test_snap_convertPositions_196() public {
        uint256 amount = 10_000_000;
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(feeBips, data);

        uint256 i = 0;
        uint256 questionCount = 196;
        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, amount);
            usdc.approve(address(nrAdapter), amount);
            nrAdapter.splitPosition(conditionId, amount);
            vm.stopPrank();

            ++i;
        }

        vm.startPrank(alice);
        ctf.setApprovalForAll(address(nrAdapter), true);

        vm.startSnapshotGas("NegRiskAdapter_convertPositions_196");
        nrAdapter.convertPositions(marketId, 1, amount);
        vm.stopSnapshotGas();
    }
}
