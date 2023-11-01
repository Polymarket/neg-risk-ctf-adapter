// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {CTFExchange} from "lib/ctf-exchange/src/exchange/CTFExchange.sol";
import {ERC1155} from "lib/solmate/src/tokens/ERC1155.sol";

contract NegRiskCtfExchange is CTFExchange {
    constructor(address _collateral, address _negRiskAdapter, address _ctf, address _proxyFactory, address _safeFactory)
        CTFExchange(_collateral, _negRiskAdapter, _proxyFactory, _safeFactory)
    {
        ERC1155(_ctf).setApprovalForAll(_negRiskAdapter, true);
    }
}
