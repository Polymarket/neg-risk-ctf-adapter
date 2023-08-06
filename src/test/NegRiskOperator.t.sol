// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "../dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {NegRiskOperator, INegRiskOperatorEE} from "src/NegRiskOperator.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskOperatorTest is TestHelper, INegRiskOperatorEE {
    NegRiskAdapter nrAdapter;
    NegRiskOperator nrOperator;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    uint256[] payoutsTrue = [1, 0];
    uint256[] payoutsFalse = [0, 1];

    function setUp() public {
        vault = _getAndLabelAddress("vault");
        oracle = _getAndLabelAddress("oracle");
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        vm.prank(alice);
        nrOperator = new NegRiskOperator(address(nrAdapter));

        vm.prank(alice);
        nrOperator.setOracle(oracle);
    }

    function test_initialState() public {
        assertEq(nrOperator.oracle(), oracle);
        assertEq(address(nrOperator.nrAdapter()), address(nrAdapter));
        assertEq(nrOperator.isAdmin(alice), true);
    }

    /*//////////////////////////////////////////////////////////////
                               SET ORACLE
    //////////////////////////////////////////////////////////////*/

    function test_setOracle(address _oracle) public {
        vm.startPrank(alice);
        NegRiskOperator nro = new NegRiskOperator(address(0));
        nro.setOracle(_oracle);
        assertEq(nro.oracle(), _oracle);
    }

    function test_revert_setOracle_oracleAlreadyIntialized(address _oracle1, address _oracle2) public {
        vm.startPrank(alice);
        NegRiskOperator nro = new NegRiskOperator(address(0));
        nro.setOracle(_oracle1);

        vm.expectRevert(OracleAlreadyInitialized.selector);
        nro.setOracle(_oracle2);
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    function test_prepareMarket(uint256 _feeBips, bytes memory _data) public {
        _feeBips = bound(_feeBips, 0, 10_000);

        vm.expectEmit();
        emit MarketPrepared(NegRiskIdLib.getMarketId(address(nrOperator), _feeBips, _data), _feeBips, _data);

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(_feeBips, _data);

        assertEq(marketId, NegRiskIdLib.getMarketId(address(nrOperator), _feeBips, _data));
        assertEq(nrAdapter.getFeeBips(marketId), _feeBips);
        assertEq(nrAdapter.getOracle(marketId), address(nrOperator));
        assertEq(nrAdapter.getQuestionCount(marketId), 0);
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    function test_prepareQuestion(bytes32 _requestId) public {
        bytes memory data = bytes("question");
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.expectEmit();
        emit QuestionPrepared(marketId, NegRiskIdLib.getQuestionId(marketId, 0), _requestId, 0, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        assertEq(nrAdapter.getQuestionCount(marketId), 1);
        assertEq(NegRiskIdLib.getMarketId(questionId), marketId);
    }

    function test_revert_prepareQuestion_questionWithRequestIdAlreadyPrepared(bytes32 _requestId) public {
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId1 = nrOperator.prepareMarket(feeBips, "market1");

        vm.prank(alice);
        nrOperator.prepareQuestion(marketId1, "", _requestId);

        vm.prank(alice);
        bytes32 marketId2 = nrOperator.prepareMarket(feeBips, "market2");

        vm.prank(alice);
        vm.expectRevert(QuestionWithRequestIdAlreadyPrepared.selector);
        nrOperator.prepareQuestion(marketId2, "", _requestId);
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT PAYOUTS
    //////////////////////////////////////////////////////////////*/

    function test_reportPayouts(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        assertEq(nrOperator.results(questionId), _result);
        assertEq(nrOperator.reportedAt(questionId), block.timestamp);
    }

    function test_revert_reportPayouts_invalidPayoutsLength(bytes32 _requestId, uint8 _payoutsLength) public {
        vm.assume(_payoutsLength != 2);

        uint256[] memory payouts = new uint256[](_payoutsLength);

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(0, "market");

        vm.prank(alice);
        nrOperator.prepareQuestion(marketId, "question", _requestId);

        vm.expectRevert(InvalidPayouts.selector);
        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, payouts);
    }

    function test_revert_reportPayouts_invalidPayoutsValues(bytes32 _requestId, uint8 _payout1, uint8 _payout2)
        public
    {
        vm.assume((_payout1 == 0 && _payout2 == 0) || (_payout1 > 0 && _payout2 > 0));

        uint256[] memory payouts = new uint256[](2);
        payouts[0] = _payout1;
        payouts[1] = _payout2;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(0, "market");

        vm.prank(alice);
        nrOperator.prepareQuestion(marketId, "question", _requestId);

        vm.expectRevert(InvalidPayouts.selector);
        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, payouts);
    }

    function test_revert_reportPayouts_invalidRequestId(bytes32 _requestId, bool _result) public {
        uint256[] memory payouts = _result ? payoutsTrue : payoutsFalse;

        vm.expectRevert(InvalidRequestId.selector);
        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, payouts);
    }

    function test_revert_reportPayouts_questionAlreadyReported(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        vm.expectRevert(QuestionAlreadyReported.selector);
        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);
    }

    /*//////////////////////////////////////////////////////////////
                            RESOLVE QUESTION
    //////////////////////////////////////////////////////////////*/

    function test_resolveQuestion(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        skip(nrOperator.DELAY_PERIOD());

        vm.expectEmit();
        emit QuestionResolved(questionId, _result);
        nrOperator.resolveQuestion(questionId);

        bytes32 conditionId = nrAdapter.getConditionId(questionId);
        assertEq(ctf.payoutDenominator(conditionId), 1);
        assertEq(ctf.payoutNumerators(conditionId, 0), _result ? 1 : 0);
        assertEq(ctf.payoutNumerators(conditionId, 1), _result ? 0 : 1);
    }

    function test_revert_resolveQuestion_resultNotAvailable(bytes32 _requestId) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.expectRevert(ResultNotAvailable.selector);
        nrOperator.resolveQuestion(questionId);
    }

    function test_revert_resolveQuestion_delayPeriodNotOver(bytes32 _requestId, bool _result, uint256 _timestamp)
        public
    {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(oracle);
        nrOperator.reportPayouts(_requestId, _result ? payoutsTrue : payoutsFalse);

        assertEq(nrOperator.reportedAt(questionId), block.timestamp);

        uint256 earliestResolvableTimestamp = block.timestamp + nrOperator.DELAY_PERIOD();
        _timestamp = bound(_timestamp, 0, earliestResolvableTimestamp - 1);
        vm.warp(_timestamp);

        vm.expectRevert(DelayPeriodNotOver.selector);
        nrOperator.resolveQuestion(questionId);
    }

    /*//////////////////////////////////////////////////////////////
                             FLAG QUESTION
    //////////////////////////////////////////////////////////////*/

    function test_flagQuestion(bytes32 _questionId) public {
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);

        assertEq(nrOperator.flaggedAt(_questionId), block.timestamp);
    }

    function test_revert_flagQuestion_notAdmin(bytes32 _questionId) public {
        vm.expectRevert(NotAdmin.selector);
        vm.prank(brian);
        nrOperator.flagQuestion(_questionId);
    }

    function test_revert_flagQuestion_onlyNotFlagged(bytes32 _questionId) public {
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);

        vm.expectRevert(OnlyNotFlagged.selector);
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);
    }

    /*//////////////////////////////////////////////////////////////
                            UNFLAG QUESTION
    //////////////////////////////////////////////////////////////*/

    function test_unflagQuestion(bytes32 _questionId) public {
        vm.prank(alice);
        nrOperator.flagQuestion(_questionId);

        vm.prank(alice);
        nrOperator.unflagQuestion(_questionId);

        assertEq(nrOperator.flaggedAt(_questionId), 0);
    }

    function test_revert_unflagQuestion_onlyFlagged(bytes32 _questionId) public {
        vm.expectRevert(OnlyFlagged.selector);
        vm.prank(alice);
        nrOperator.unflagQuestion(_questionId);
    }

    function test_revert_unflagQuestion_onlyAdmin(bytes32 _questionId) public {
        vm.expectRevert(NotAdmin.selector);
        vm.prank(brian);
        nrOperator.unflagQuestion(_questionId);
    }

    /*//////////////////////////////////////////////////////////////
                       EMERGENCY RESOLVE QUESTION
    //////////////////////////////////////////////////////////////*/

    function test_emergencyResolveQuestion(bytes32 _requestId, bool _result) public {
        bytes memory data = new bytes(0);
        uint256 feeBips = 0;

        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(feeBips, data);

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, _requestId);

        vm.prank(alice);
        nrOperator.flagQuestion(questionId);

        skip(nrOperator.DELAY_PERIOD());

        vm.expectEmit();
        emit QuestionEmergencyResolved(questionId, _result);

        vm.prank(alice);
        nrOperator.emergencyResolveQuestion(questionId, _result);
    }

    function test_revert_emergencyResolveQuestion_onlyFlagged(bytes32 _questionId, bool _result) public {
        vm.prank(alice);
        vm.expectRevert(OnlyFlagged.selector);
        nrOperator.emergencyResolveQuestion(_questionId, _result);
    }

    function test_revert_emergencyResolveQuestion_delayPeriodNotOver(
        bytes32 _requestId,
        bool _result,
        uint256 _timestamp
    ) public {
        vm.prank(alice);
        bytes32 marketId = nrOperator.prepareMarket(0, "");

        vm.prank(alice);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, "", _requestId);

        vm.prank(alice);
        nrOperator.flagQuestion(questionId);

        uint256 earliestResolvableTimestamp = block.timestamp + nrOperator.DELAY_PERIOD();
        _timestamp = bound(_timestamp, 0, earliestResolvableTimestamp - 1);

        vm.warp(_timestamp);

        vm.prank(alice);
        vm.expectRevert(DelayPeriodNotOver.selector);
        nrOperator.emergencyResolveQuestion(questionId, _result);
    }

    /*//////////////////////////////////////////////////////////////
                                FALLBACK
    //////////////////////////////////////////////////////////////*/

    function test_fallback(address _oracle, bytes32 _questionId, uint256 _outcomeSlotCount) public {
        IConditionalTokens(address(nrOperator)).prepareCondition(_oracle, _questionId, _outcomeSlotCount);
    }
}
