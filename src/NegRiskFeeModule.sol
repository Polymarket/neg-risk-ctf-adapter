// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {FeeModule, IExchange} from "../lib/exchange-fee-module/src/FeeModule.sol";
import {IConditionalTokens} from "./interfaces/IConditionalTokens.sol";

contract NegRiskFeeModule is FeeModule {
    constructor(address _negRiskCtfExchange, address _negRiskAdapter, address _ctf) FeeModule(_negRiskCtfExchange) {
        IConditionalTokens(_ctf).setApprovalForAll(_negRiskAdapter, true);
        IConditionalTokens(_ctf).setApprovalForAll(_negRiskCtfExchange, true);
        IConditionalTokens(_ctf).setApprovalForAll(address(this), true);
    }
}
