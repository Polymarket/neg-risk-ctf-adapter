pragma solidity ^0.8.15;

import {ICTFExchange} from "./ICTFExchange.sol";

interface IFeeModule {
    event FeeRefunded(address token, address to, uint256 id, uint256 amount);
    event FeeWithdrawn(address token, address to, uint256 id, uint256 amount);
    event NewAdmin(address indexed admin, address indexed newAdminAddress);
    event RemovedAdmin(address indexed admin, address indexed removedAdmin);

    function addAdmin(address admin) external;
    function admins(address) external view returns (uint256);
    function collateral() external view returns (address);
    function ctf() external view returns (address);
    function exchange() external view returns (address);
    function isAdmin(address addr) external view returns (bool);
    function matchOrders(
        ICTFExchange.Order memory takerOrder,
        ICTFExchange.Order[] memory makerOrders,
        uint256 takerFillAmount,
        uint256[] memory makerFillAmounts,
        uint256 makerFeeRate
    ) external;
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        external
        returns (bytes4);
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4);
    function removeAdmin(address admin) external;
    function renounceAdmin() external;
    function withdrawFees(address to, uint256 id, uint256 amount) external;
}
