// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Test, console2 as console} from "lib/forge-std/src/Test.sol";

import {TestHelper, console} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

contract NegRiskAdapterInvariantsHandler is Test {
    NegRiskAdapter public nra;
    USDC public usdc;
    uint256 public val;
    uint256 public x = 1;
    bytes32 marketId;

    constructor(address _usdc, address _nra, bytes32 _marketId) {
        nra = NegRiskAdapter(_nra);
        usdc = USDC(_usdc);
        marketId = _marketId;
    }

    function split(uint8 _index, uint256 _amount) public {
        _index %= 16;

        // vm.startPrank(alice);
        usdc.mint(address(this), _amount);
        usdc.approve(address(nra), _amount);

        bytes32 questionId = NegRiskIdLib.getQuestionId(marketId, _index);
        bytes32 conditionId = nra.getConditionId(questionId);
        nra.splitPosition(conditionId, _amount);
        vm.stopPrank();
    }
}

contract NegRiskAdapterInvariants is Test {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    NegRiskAdapterInvariantsHandler handler;

    address oracle;
    address vault;

    function setUp() public {
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        oracle = address(bytes20(keccak256("oracle")));
        uint256 questionCount = 16;
        uint8 i = 0;

        bytes memory data = new bytes(0);
        vm.prank(oracle);
        bytes32 marketId = nrAdapter.prepareMarket(0, data);

        while (i < questionCount) {
            vm.prank(oracle);
            bytes32 questionId = nrAdapter.prepareQuestion(marketId, data);
            ++i;
        }

        handler = new NegRiskAdapterInvariantsHandler(address(usdc), address(nrAdapter), marketId);

        targetContract(address(handler));
    }

    function invariant_badInvariantThisShouldFail() public {
        assertEq(usdc.balanceOf(address(wcol)), wcol.balanceOf(address(ctf)));
    }
}
