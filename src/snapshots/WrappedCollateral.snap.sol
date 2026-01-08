// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "src/dev/TestHelper.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";

import {WrappedCollateral} from "src/WrappedCollateral.sol";

contract WrappedCollateralSnapshots is TestHelper {
    USDC usdc;
    WrappedCollateral wcol;
    address owner;

    function setUp() public {
        usdc = new USDC();
        owner = vm.createWallet("owner").addr;

        uint8 decimals = usdc.decimals();

        vm.prank(owner);
        wcol = new WrappedCollateral(address(usdc), decimals);
    }

    function test_mintAndBurn() public {
        uint256 amount = 10_000_000;

        vm.startPrank(owner);

        vm.startSnapshotGas("WrappedCollateral_mint");
        wcol.mint(amount);
        vm.stopSnapshotGas();

        vm.startSnapshotGas("WrappedCollateral_burn");
        wcol.burn(amount);
        vm.stopSnapshotGas();

        vm.stopPrank();
    }

    function test_wrapAndUnwrap() public {
        uint256 amount = 10_000_000;

        usdc.mint(owner, amount);
        vm.startPrank(owner);

        usdc.approve(address(wcol), amount);

        vm.startSnapshotGas("WrappedCollateral_wrap");
        wcol.wrap(brian, amount);
        vm.stopSnapshotGas();

        vm.stopPrank();

        vm.startPrank(brian);

        vm.startSnapshotGas("WrappedCollateral_unwrap");
        wcol.unwrap(alice, amount);
        vm.stopSnapshotGas();

        vm.stopPrank();
    }
}
