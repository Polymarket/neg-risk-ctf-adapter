// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";

/// @title IWrappedCollateralEE
/// @notice WrappedCollateral Errors and Events
interface IWrappedCollateralEE {
    error OnlyOwner();
}

string constant NAME = "Wrapped Collateral";
string constant SYMBOL = "WCOL";

/// @title WrappedCollateral
/// @author Mike Shrieve (mike@polymarket.com)
/// @notice Wraps an ERC20 token to be used as collateral in the CTF
contract WrappedCollateral is IWrappedCollateralEE, ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    address public immutable owner;
    address public immutable underlying;

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyOwner() {
        if (msg.sender != owner) revert OnlyOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _underlying The address of the underlying ERC20 token
    /// @param _decimals The number of decimals of the underlying ERC20 token
    constructor(address _underlying, uint8 _decimals) ERC20(NAME, SYMBOL, _decimals) {
        owner = msg.sender;
        underlying = _underlying;
    }

    /*//////////////////////////////////////////////////////////////
                                 UNWRAP
    //////////////////////////////////////////////////////////////*/

    /// @notice Unwraps the specified amount of tokens
    /// @param _to The address to send the unwrapped tokens to
    /// @param _amount The amount of tokens to unwrap
    function unwrap(address _to, uint256 _amount) external {
        _burn(msg.sender, _amount);
        ERC20(underlying).transfer(_to, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                                 ADMIN
    //////////////////////////////////////////////////////////////*/

    /// @notice Wraps the specified amount of tokens
    /// @notice Can only be called by the owner
    /// @param _to The address to send the wrapped tokens to
    /// @param _amount The amount of tokens to wrap
    function wrap(address _to, uint256 _amount) external onlyOwner {
        ERC20(underlying).transferFrom(msg.sender, address(this), _amount);
        _mint(_to, _amount);
    }

    /// @notice Burns the specified amount of tokens
    /// @notice Can only be called by the owner
    /// @param _amount The amount of tokens to burn
    function burn(uint256 _amount) external onlyOwner {
        _burn(msg.sender, _amount);
    }

    /// @notice Mints the specified amount of tokens
    /// @notice Can only be called by the owner
    /// @param _amount The amount of tokens to mint
    function mint(uint256 _amount) external onlyOwner {
        _mint(msg.sender, _amount);
    }

    /// @notice Releases the specified amount of the underlying token
    /// @notice Can only be called by the owner
    /// @param _to The address to send the released tokens to
    /// @param _amount The amount of tokens to release
    function release(address _to, uint256 _amount) external onlyOwner {
        ERC20(underlying).transfer(_to, _amount);
    }
}
