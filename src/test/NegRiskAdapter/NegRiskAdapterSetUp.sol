// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "../../NegRiskAdapter.sol";
import {WrappedCollateral} from "../../WrappedCollateral.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {USDC} from "../../test/mock/USDC.sol";
import {IConditionalTokens} from "../../interfaces/IConditionalTokens.sol";

contract NegRiskAdapter_SetUp is TestHelper, INegRiskAdapterEE {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address oracle;
    address vault;

    uint256 constant FEE_BIPS_MAX = 10_000;

    function setUp() public virtual {
        vault = vm.createWallet("vault").addr;
        oracle = vm.createWallet("oracle").addr;
        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();
    }
}
