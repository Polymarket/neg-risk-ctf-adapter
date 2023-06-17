// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {NegRiskAdapter} from "./NegRiskAdapter.sol";
import {IUmaCtfAdapter} from "./interfaces/IUmaCtfAdapter.sol";
import {Auth} from "./modules/Auth.sol";
import {ERC1155TokenReceiver} from "../lib/solmate/src/tokens/ERC1155.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IERC1155} from "./interfaces/IConditionalTokens.sol";

contract Vault is Auth, ERC1155TokenReceiver {
    function transferERC20(
        address _erc20,
        address _to,
        uint256 _amount
    ) external onlyAdmin {
        IERC20(_erc20).transfer(_to, _amount);
    }

    function transferERC1155(
        address _erc1155,
        address _to,
        uint256 _id,
        uint256 _value
    ) external onlyAdmin {
        IERC1155(_erc1155).safeTransferFrom(
            address(this),
            _to,
            _id,
            _value,
            ""
        );
    }

    function batchTransferERC1155(
        address _erc1155,
        address _to,
        uint256[] calldata _ids,
        uint256[] calldata _values
    ) external onlyAdmin {
        IERC1155(_erc1155).safeBatchTransferFrom(
            address(this),
            _to,
            _ids,
            _values,
            ""
        );
    }
}
