// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC1155TokenReceiver} from "lib/solmate/src/tokens/ERC1155.sol";

import {NegRiskAdapter} from "src/NegRiskAdapter.sol";
import {Auth} from "src/modules/Auth.sol";
import {IERC1155} from "src/interfaces/IConditionalTokens.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {IUmaCtfAdapter} from "src/interfaces/IUmaCtfAdapter.sol";

/// @title Vault
/// @author Mike Shrieve (mike@polymarket.com)
contract Vault is Auth, ERC1155TokenReceiver {
    /*//////////////////////////////////////////////////////////////
                                 ERC20
    //////////////////////////////////////////////////////////////*/

    function transferERC20(address _erc20, address _to, uint256 _amount) external onlyAdmin {
        IERC20(_erc20).transfer(_to, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                                ERC1155
    //////////////////////////////////////////////////////////////*/

    function transferERC1155(address _erc1155, address _to, uint256 _id, uint256 _value) external onlyAdmin {
        IERC1155(_erc1155).safeTransferFrom(address(this), _to, _id, _value, "");
    }

    function batchTransferERC1155(address _erc1155, address _to, uint256[] calldata _ids, uint256[] calldata _values)
        external
        onlyAdmin
    {
        IERC1155(_erc1155).safeBatchTransferFrom(address(this), _to, _ids, _values, "");
    }
}
