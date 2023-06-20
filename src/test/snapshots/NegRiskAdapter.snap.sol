// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {TestHelper} from "src/dev/TestHelper.sol";
import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapterSnapshots is TestHelper, GasSnapshot {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    address oracle;
    IConditionalTokens ctf;

    function setUp() public {
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), address(0));
        oracle = _getAndLabelAddress("oracle");
    }

    function test_snap_prepareMarket() public {
        bytes memory data = new bytes(128);
        uint256 feeBips = 1_00;

        vm.startPrank(oracle);

        snapStart("NegRiskAdapter_prepareMarket");
        nrAdapter.prepareMarket(data, feeBips);
        snapEnd();
    }

    function test_snap_prepareQuestion() public {
        bytes memory data = new bytes(128);
        uint256 feeBips = 1_00;

        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);

        uint256 i = 0;

        while (i < 16) {
            nrAdapter.prepareQuestion(marketId, data);
            assertEq(nrAdapter.getQuestionCount(marketId), i + 1);
            ++i;
        }

        snapStart("NegRiskAdapter_prepareQuestion");
        nrAdapter.prepareQuestion(marketId, data);
        snapEnd();
    }

    function test_snap_splitPosition() public {
        uint256 amount = 10_000_000;
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);
        bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice

        vm.startPrank(alice);
        usdc.mint(alice, 3 * amount);
        usdc.approve(address(nrAdapter), 2 * amount);
        nrAdapter.splitPosition(conditionId, amount);

        // no balances should zero before _or_ after snap
        snapStart("NegRiskAdapter_splitPosition");
        nrAdapter.splitPosition(conditionId, amount);
        snapEnd();
    }

    function test_snap_mergePositions() public {
        uint256 amount = 10_000_000;
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(data, feeBips);
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
        snapStart("NegRiskAdapter_mergePositions");
        nrAdapter.mergePositions(conditionId, amount);
        snapEnd();
    }
}
