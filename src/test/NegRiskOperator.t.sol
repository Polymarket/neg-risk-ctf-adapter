// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TestHelper, console} from "../dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {NegRiskOperator} from "src/NegRiskOperator.sol";

contract NegRiskOperatorTest is TestHelper {
    NegRiskAdapter nrAdapter;
    NegRiskOperator nrOperator;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    function setUp() public {
        vault = _getAndLabelAddress("vault");
        oracle = _getAndLabelAddress("oracle");
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        nrOperator = new NegRiskOperator(address(nrAdapter), oracle);
    }
}
