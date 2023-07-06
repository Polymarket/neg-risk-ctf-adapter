// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapter_SplitPosition_Test is NegRiskAdapter_SetUp {
    bytes32 marketId;
    bytes32 questionId;
    bytes32 conditionId;

    function _before(uint256 _amount) internal {
        uint256 feeBips = 0;
        bytes memory data = new bytes(0);

        // prepare question
        vm.startPrank(oracle);
        marketId = nrAdapter.prepareMarket(feeBips, data);
        questionId = nrAdapter.prepareQuestion(marketId, data);
        conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();
        // split position to alice

        usdc.mint(alice, _amount);

        vm.prank(alice);
        usdc.approve(address(nrAdapter), _amount);
    }

    function _after(uint256 _amount) internal {
        // check collateral balances
        assertEq(usdc.balanceOf(address(wcol)), _amount);
        assertEq(wcol.totalSupply(), _amount);
        assertEq(wcol.balanceOf(address(ctf)), _amount);

        // check position token balances
        uint256 positionIdFalse = nrAdapter.getPositionId(questionId, false);
        assertEq(ctf.balanceOf(alice, positionIdFalse), _amount);
        uint256 positionIdTrue = nrAdapter.getPositionId(questionId, true);
        assertEq(ctf.balanceOf(alice, positionIdTrue), _amount);
    }

    function test_splitPosition(uint256 _amount) public {
        _before(_amount);

        vm.prank(alice);
        nrAdapter.splitPosition(conditionId, _amount);

        _after(_amount);
    }

    function test_splitPosition_asCTF(uint256 _amount) public {
        _before(_amount);

        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.prank(alice);
        IConditionalTokens(address(nrAdapter)).splitPosition(address(usdc), bytes32(0), conditionId, partition, _amount);

        _after(_amount);
    }

    function test_revert_splitPosition_asCTF_wrongCollateralType(uint256 _amount, address _collateral) public {
        vm.assume(_collateral != address(usdc));

        _before(_amount);

        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.expectRevert(UnexpectedCollateralToken.selector);
        IConditionalTokens(address(nrAdapter)).splitPosition(_collateral, bytes32(0), conditionId, partition, _amount);
    }
}
