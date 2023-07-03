// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";

contract NegRiskAdapterInvariantsHandler {
    NegRiskAdapter public nra;

    constructor(address _nra) {
        nra = NegRiskAdapter(_nra);
    }

    function one() public pure returns (uint256) {
        return 2;
    }
}

contract NegRiskAdapterInvariants is TestHelper {
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

        handler = new NegRiskAdapterInvariantsHandler(address(nrAdapter));
        targetContract(address(handler));
    }

    function invariant_testInvariant() public {
        uint256 x = 3;
        assertEq(x, 4);
        assertEq(1, handler.one());
    }
}
