// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";

contract NegRiskAdapter_PrepareMarket_Test is NegRiskAdapter_SetUp {
    function test_prepareMarket(uint256 _feeBips, bytes memory _data) public {
        _feeBips = bound(_feeBips, 0, 1_00_00);

        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(_feeBips, _data);

        assertEq(nrAdapter.getFeeBips(marketId), _feeBips);
        assertEq(nrAdapter.getOracle(marketId), oracle);
        assertEq(nrAdapter.getQuestionCount(marketId), 0);
        assertEq(nrAdapter.getDetermined(marketId), false);
        assertEq(nrAdapter.getResult(marketId), 0);
    }

    function test_revert_prepareMarketTwice(bytes memory _data, uint256 _feeBips) public {
        _feeBips = bound(_feeBips, 0, 1_00_00);

        vm.startPrank(oracle);
        nrAdapter.prepareMarket(_feeBips, _data);

        vm.expectRevert(MarketAlreadyPrepared.selector);
        nrAdapter.prepareMarket(_feeBips, _data);
    }
}
