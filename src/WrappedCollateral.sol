// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "../lib/solmate/src/tokens/ERC20.sol";

interface IWrappedCollateralEE {
    error OnlyOwner();
}

contract WrappedCollateral is IWrappedCollateralEE, ERC20 {
    address public immutable owner;
    address public immutable underlying;

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    constructor(
        address _underlying,
        uint8 _decimals
    ) ERC20("Wrapped Collateral", "WC", _decimals) {
        owner = msg.sender;
        underlying = _underlying;
    }

    /*//////////////////////////////////////////////////////////////
                             WRAP / UNWRAP
    //////////////////////////////////////////////////////////////*/

    function wrap(address _to, uint256 _amount) external {
        ERC20(underlying).transferFrom(msg.sender, address(this), _amount);
        _mint(_to, _amount);
    }

    function unwrap(address _to, uint256 _amount) external {
        _burn(msg.sender, _amount);
        ERC20(underlying).transfer(_to, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                                 ADMIN
    //////////////////////////////////////////////////////////////*/

    function burn(uint256 _amount) external onlyOwner {
        _burn(msg.sender, _amount);
    }

    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    function release(address _to, uint256 _amount) external onlyOwner {
        ERC20(underlying).transfer(_to, _amount);
    }
}
