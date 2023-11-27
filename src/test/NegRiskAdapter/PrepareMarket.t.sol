// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapter_PrepareMarket_Test is NegRiskAdapter_SetUp {
    function test_prepareMarket(uint256 _feeBips, bytes memory _data) public {
        _feeBips = bound(_feeBips, 0, FEE_BIPS_MAX);

        bytes32 expectedMarketId = NegRiskIdLib.getMarketId(oracle, _feeBips, _data);

        vm.expectEmit();
        emit MarketPrepared(expectedMarketId, oracle, _feeBips, _data);

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(_feeBips, _data);

        assertEq(marketId, expectedMarketId);
        assertEq(nrAdapter.getFeeBips(marketId), _feeBips);
        assertEq(nrAdapter.getOracle(marketId), oracle);
        assertEq(nrAdapter.getQuestionCount(marketId), 0);
        assertEq(nrAdapter.getDetermined(marketId), false);
        assertEq(nrAdapter.getResult(marketId), 0);
    }

    function test_revert_prepareMarketTwice(bytes memory _data, uint256 _feeBips) public {
        _feeBips = bound(_feeBips, 0, FEE_BIPS_MAX);

        vm.startPrank(oracle);
        nrAdapter.prepareMarket(_feeBips, _data);

        vm.expectRevert(MarketAlreadyPrepared.selector);
        nrAdapter.prepareMarket(_feeBips, _data);
    }

    function test_revert_feeBipsOutOfBounds(bytes memory _data, uint256 _feeBips) public {
        _feeBips = bound(_feeBips, FEE_BIPS_MAX + 1, type(uint256).max);

        vm.expectRevert(FeeBipsOutOfBounds.selector);
        vm.startPrank(oracle);
        nrAdapter.prepareMarket(_feeBips, _data);
    }
}
