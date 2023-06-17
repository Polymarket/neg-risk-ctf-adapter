// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../dev/TestHelper.sol";

import {NegRiskAdapter} from "../NegRiskAdapter.sol";
import {WrappedCollateral} from "../WrappedCollateral.sol";
import {DeployLib} from "../dev/libraries/DeployLib.sol";
import {USDC} from "./mock/USDC.sol";

contract MathTest is TestHelper {
    function test_distributiveProperty(uint64 _a, uint64 _b, uint64 _c) public {
        uint256 a = uint256(_a);
        uint256 b = uint256(_b);
        uint256 c = uint256(_b) + uint256(_c);

        assertEq(a * (c - b), a * c - a * b);
    }
}
