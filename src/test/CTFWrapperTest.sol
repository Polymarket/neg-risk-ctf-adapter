// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../dev/TestHelper.sol";

import {CTFWrapper} from "../CTFWrapper.sol";
import {PUSDC} from "../PUSDC.sol";
import {DeployLib} from "../dev/libraries/DeployLib.sol";
import {USDC} from "./mock/USDC.sol";

contract CTFWrapperTest is TestHelper, IAuthEE {
    CTFWrapper ctfWrapper;
    USDC usdc;
    PUSDC pusdc;

    function setUp() public {
        address ctf = DeployLib.deployConditionalTokens();
        usdc = new USDC();
        ctfWrapper = new CTFWrapper(ctf, address(usdc));
    }
}
