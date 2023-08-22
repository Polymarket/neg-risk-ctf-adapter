// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";
import {ERC1155TokenReceiver} from "lib/solmate/src/tokens/ERC1155.sol";

import {Auth} from "src/modules/Auth.sol";
import {IERC1155} from "src/interfaces/IConditionalTokens.sol";

/// @title Vault
/// @notice A contract for holding ERC20 and ERC1155 tokens for the NegRiskAdapter
/// @author Mike Shrieve (mike@polymarket.com)
contract Vault is Auth, ERC1155TokenReceiver {
    using SafeTransferLib for ERC20;

    /*//////////////////////////////////////////////////////////////
                                 ERC20
    //////////////////////////////////////////////////////////////*/

    /// @notice Transfer ERC20 tokens from the Vault
    /// @notice OnlyAdmin
    /// @param _erc20  - the address of the ERC20 token
    /// @param _to     - the address to send the tokens to
    /// @param _amount - the amount of tokens to send
    function transferERC20(address _erc20, address _to, uint256 _amount) external onlyAdmin {
        ERC20(_erc20).safeTransfer(_to, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                                ERC1155
    //////////////////////////////////////////////////////////////*/

    /// @notice Transfer ERC1155 tokens from the Vault
    /// @notice OnlyAdmin
    /// @param _erc1155 - the address of the ERC1155 token
    /// @param _to      - the address to send the tokens to
    /// @param _id      - the id of the token to send
    /// @param _value   - the amount of tokens to send
    function transferERC1155(address _erc1155, address _to, uint256 _id, uint256 _value) external onlyAdmin {
        IERC1155(_erc1155).safeTransferFrom(address(this), _to, _id, _value, "");
    }

    /// @notice Batch transfer ERC1155 tokens from the Vault
    /// @notice OnlyAdmin
    /// @param _erc1155 - the address of the ERC1155 token
    /// @param _to      - the address to send the tokens to
    /// @param _ids     - the ids of the tokens to send
    /// @param _values  - the amounts of tokens to send
    function batchTransferERC1155(address _erc1155, address _to, uint256[] calldata _ids, uint256[] calldata _values)
        external
        onlyAdmin
    {
        IERC1155(_erc1155).safeBatchTransferFrom(address(this), _to, _ids, _values, "");
    }
}
