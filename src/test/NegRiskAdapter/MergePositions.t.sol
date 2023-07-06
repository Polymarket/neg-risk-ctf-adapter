// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapter_MergePositions_Test is NegRiskAdapter_SetUp {
    bytes32 marketId;
    bytes32 questionId;
    bytes32 conditionId;
    uint256 positionIdFalse;
    uint256 positionIdTrue;

    function _before(uint256 _amount) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        // prepare question
        vm.startPrank(oracle);
        marketId = nrAdapter.prepareMarket(feeBips, data);
        questionId = nrAdapter.prepareQuestion(marketId, data);
        conditionId = nrAdapter.getConditionId(questionId);
        vm.stopPrank();

        // split position to alice
        vm.startPrank(alice);
        usdc.mint(alice, _amount);
        usdc.approve(address(nrAdapter), _amount);
        nrAdapter.splitPosition(conditionId, _amount);

        positionIdFalse = nrAdapter.getPositionId(questionId, false);
        ctf.safeTransferFrom(alice, brian, positionIdFalse, _amount, "");

        positionIdTrue = nrAdapter.getPositionId(questionId, true);
        ctf.safeTransferFrom(alice, brian, positionIdTrue, _amount, "");

        vm.stopPrank();

        vm.prank(brian);
        ctf.setApprovalForAll(address(nrAdapter), true);
    }

    function _after(uint256 _amount) public {
        assertEq(usdc.balanceOf(brian), _amount);
        assertEq(wcol.totalSupply(), 0);
        assertEq(ctf.balanceOf(brian, positionIdFalse), 0);
        assertEq(ctf.balanceOf(brian, positionIdTrue), 0);
    }

    function test_mergePositions(uint256 _amount) public {
        _before(_amount);

        vm.prank(brian);
        nrAdapter.mergePositions(conditionId, _amount);

        _after(_amount);
    }

    function test_mergePositions_asCtf(uint256 _amount) public {
        _before(_amount);

        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.prank(brian);
        IConditionalTokens(address(nrAdapter)).mergePositions(
            address(usdc), bytes32(0), conditionId, partition, _amount
        );

        _after(_amount);
    }

    function test_revert_mergePositions_asCTF_wrongCollateralType(uint256 _amount, address _collateral) public {
        vm.assume(_collateral != address(usdc));

        _before(_amount);

        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.expectRevert(UnexpectedCollateralToken.selector);
        IConditionalTokens(address(nrAdapter)).mergePositions(_collateral, bytes32(0), conditionId, partition, _amount);
    }
}
