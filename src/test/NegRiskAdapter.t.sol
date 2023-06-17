// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../dev/TestHelper.sol";

import {NegRiskAdapter} from "../NegRiskAdapter.sol";
import {WrappedCollateral} from "../WrappedCollateral.sol";
import {DeployLib} from "../dev/libraries/DeployLib.sol";
import {USDC} from "./mock/USDC.sol";

contract NegRiskAdapterTest is TestHelper {
    NegRiskAdapter nrAdapter;
    USDC usdc;
    WrappedCollateral wcol;

    function setUp() public {
        address ctf = DeployLib.deployConditionalTokens();
        usdc = new USDC();
        nrAdapter = new NegRiskAdapter(ctf, address(usdc));
    }
}
