// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {console, NegRiskAdapter_SetUp} from "src/test/NegRiskAdapter/NegRiskAdapterSetUp.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapter_ConvertPositions_Test is NegRiskAdapter_SetUp {
    uint256 constant QUESTION_COUNT_MAX = 32;
    uint256 constant FEE_BIPS_MAX = 1_00_00;
    bytes32 marketId;

    function _before(uint256 _questionCount, uint256 _feeBips, uint256 _indexSet, uint256 _amount) internal {
        bytes memory data = new bytes(0);

        // prepare market
        vm.prank(oracle);
        marketId = nrAdapter.prepareMarket(_feeBips, data);

        uint8 i = 0;

        // prepare questions and split initial liquidity to alice
        while (i < _questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            bytes32 conditionId = nrAdapter.getConditionId(questionId);

            // // split position to alice
            vm.startPrank(alice);
            usdc.mint(alice, _amount);
            usdc.approve(address(nrAdapter), _amount);
            nrAdapter.splitPosition(conditionId, _amount);
            vm.stopPrank();

            ++i;
        }

        assertEq(nrAdapter.getQuestionCount(marketId), _questionCount);

        // send no positions to brian
        {
            i = 0;

            while (i < _questionCount) {
                if (_indexSet & (1 << i) > 0) {
                    uint256 positionId = nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), false);
                    ctf.balanceOf(alice, positionId);
                    vm.prank(alice);
                    ctf.safeTransferFrom(alice, brian, positionId, _amount, "");
                    assertEq(ctf.balanceOf(brian, positionId), _amount);
                }
                ++i;
            }
        }
    }

    function _after(uint256 _questionCount, uint256 _feeBips, uint256 _indexSet, uint256 _amount) internal {
        // check balances
        {
            uint256 feeAmount = (_amount * _feeBips) / FEE_BIPS_MAX;
            uint256 amountOut = _amount - feeAmount;

            uint8 i = 0;
            uint256 noPositionsCount;
            uint256 yesPositionsCount;

            while (i < _questionCount) {
                if (_indexSet & (1 << i) > 0) {
                    // NO
                    uint256 positionId = nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), false);

                    // brian has no more of this no token
                    assertEq(ctf.balanceOf(brian, positionId), 0);
                    // they are all at the no token burn address
                    assertEq(ctf.balanceOf(nrAdapter.noTokenBurnAddress(), positionId), _amount);
                    ++noPositionsCount;
                } else {
                    // YES
                    uint256 positionId = nrAdapter.getPositionId(NegRiskIdLib.getQuestionId(marketId, i), true);

                    // brian has _amount of each yes token, after fees
                    assertEq(ctf.balanceOf(brian, positionId), _amount - feeAmount);
                    // vault has the rest of yes tokens as fees
                    assertEq(ctf.balanceOf(vault, positionId), feeAmount);
                    ++yesPositionsCount;
                }
                ++i;
            }

            assertEq(noPositionsCount + yesPositionsCount, _questionCount);

            // brian should have (noPositionsCount -1) * amountOut USDC
            assertEq(usdc.balanceOf(brian), (noPositionsCount - 1) * amountOut);

            // the ctf should have (questionCount + yesPositionCount)*_amount WCOL
            assertEq(wcol.balanceOf(address(ctf)), _amount * (_questionCount + yesPositionsCount));
        }
    }

    function test_convertPositions(uint256 _questionCount, uint256 _feeBips, uint256 _indexSet, uint128 _amount)
        public
    {
        vm.assume(_amount > 0);

        _feeBips = bound(_feeBips, 0, FEE_BIPS_MAX);
        _questionCount = bound(_questionCount, 2, QUESTION_COUNT_MAX); // between 2 and QUESTION_COUNT_MAX questions
        _indexSet = bound(_indexSet, 1, (2 ** _questionCount) - 1);

        _before(_questionCount, _feeBips, _indexSet, _amount);

        // convert positions
        {
            vm.startPrank(brian);
            ctf.setApprovalForAll(address(nrAdapter), true);

            vm.expectEmit();
            emit PositionsConverted(brian, marketId, _indexSet, _amount);
            nrAdapter.convertPositions(marketId, _indexSet, _amount);
        }

        _after(_questionCount, _feeBips, _indexSet, _amount);
    }

    function test_convertPositions_singleIndex(
        uint256 _questionCount,
        uint256 _feeBips,
        uint256 _index,
        uint128 _amount
    ) public {
        vm.assume(_amount > 0);

        _feeBips = bound(_feeBips, 0, FEE_BIPS_MAX);
        _questionCount = bound(_questionCount, 2, QUESTION_COUNT_MAX); // between 2 and QUESTION_COUNT_MAX questions
        _index = bound(_index, 0, _questionCount - 1);
        uint256 _indexSet = 1 << _index;

        _before(_questionCount, _feeBips, _indexSet, _amount);

        // convert positions
        {
            vm.startPrank(brian);
            ctf.setApprovalForAll(address(nrAdapter), true);

            vm.expectEmit();
            emit PositionsConverted(brian, marketId, _indexSet, _amount);
            nrAdapter.convertPositions(marketId, _indexSet, _amount);
        }

        _after(_questionCount, _feeBips, _indexSet, _amount);
    }

    function test_convertPositions_allIndices(uint256 _questionCount, uint256 _feeBips, uint128 _amount) public {
        vm.assume(_amount > 0);

        _feeBips = bound(_feeBips, 0, FEE_BIPS_MAX);
        _questionCount = bound(_questionCount, 2, QUESTION_COUNT_MAX); // between 2 and QUESTION_COUNT_MAX questions
        uint256 _indexSet = (2 ** _questionCount) - 1;

        _before(_questionCount, _feeBips, _indexSet, _amount);

        // convert positions
        {
            vm.startPrank(brian);
            ctf.setApprovalForAll(address(nrAdapter), true);

            vm.expectEmit();
            emit PositionsConverted(brian, marketId, _indexSet, _amount);
            nrAdapter.convertPositions(marketId, _indexSet, _amount);
        }

        _after(_questionCount, _feeBips, _indexSet, _amount);
    }

    function test_convertPositions_zeroAmount(uint256 _a, uint256 _b) public {
        uint256 amount = 0;

        uint256 questionCountMax = 32;
        uint256 questionCount = bound(_a, 2, questionCountMax); // between 2 and 16 questions
        uint256 indexSet = bound(_b, 1, (2 ** questionCount) - 1);
        uint256 noPositionsCount;

        _before(questionCount, 0, indexSet, amount);

        {
            vm.startPrank(brian);
            ctf.setApprovalForAll(address(nrAdapter), true);

            vm.expectEmit();
            emit PositionsConverted(brian, marketId, indexSet, 0);
            nrAdapter.convertPositions(marketId, indexSet, amount);
        }
    }

    function test_revert_convertPositions_marketNotPrepared(bytes32 _marketId) public {
        vm.expectRevert(MarketNotPrepared.selector);
        nrAdapter.convertPositions(_marketId, 0, 0);
    }

    function test_revert_convertPositions_noConvertiblePositions(bytes32 _marketId) public {
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(0, "");

        // 0 questions prepared
        vm.expectRevert(NoConvertiblePositions.selector);
        nrAdapter.convertPositions(marketId, 0, 0);

        vm.prank(oracle);
        nrAdapter.prepareQuestion(marketId, "");

        // 1 question prepared
        vm.expectRevert(NoConvertiblePositions.selector);
        nrAdapter.convertPositions(marketId, 0, 0);

        vm.prank(oracle);
        nrAdapter.prepareQuestion(marketId, "");

        // 2 positions prepared
        vm.expectRevert(InvalidIndexSet.selector);
        nrAdapter.convertPositions(marketId, 0, 0);
    }

    function test_revert_convertPositions_invalidIndexSet(uint256 _a, uint256 _b, uint256 _c, uint128 _amount) public {
        vm.assume(_amount > 0);

        // 10%
        uint256 feeBips = 10_000;

        uint256 questionCountMax = 32;
        uint256 questionCount = bound(_a, 2, questionCountMax); // between 2 and 16 questions
        uint256 indexSet = bound(_b, 1, (2 ** questionCount) - 1);

        _before(questionCount, feeBips, indexSet, _amount);

        uint256 zeroIndexSet = 0;
        vm.expectRevert(InvalidIndexSet.selector);
        nrAdapter.convertPositions(marketId, zeroIndexSet, 0);

        uint256 invalidIndexSet = bound(_c, 2 ** questionCount, type(uint256).max);
        vm.expectRevert(InvalidIndexSet.selector);
        nrAdapter.convertPositions(marketId, invalidIndexSet, 0);
    }
}
