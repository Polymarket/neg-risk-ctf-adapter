// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";

contract PUSDC is ERC20 {
    ERC20 immutable usdc;

    constructor(address _usdc) ERC20("Wrapped USDC", "PUSDC", 6) {
        usdc = ERC20(_usdc);
    }

    function wrap(uint256 amount) external {
        usdc.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function unwrap(uint256 amount) external {
        usdc.transfer(msg.sender, amount);
        _burn(msg.sender, amount);
    }
}
