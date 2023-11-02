// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";

import {TestHelper} from "src/dev/TestHelper.sol";
import {NegRiskAdapter} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";

contract WrappedCollateralSnapshots is TestHelper, GasSnapshot {
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

        snapStart("WrappedCollateral_mint");
        wcol.mint(amount);
        snapEnd();

        snapStart("WrappedCollateral_burn");
        wcol.burn(amount);
        snapEnd();

        vm.stopPrank();
    }

    function test_wrapAndUnwrap() public {
        uint256 amount = 10_000_000;

        usdc.mint(owner, amount);
        vm.startPrank(owner);

        usdc.approve(address(wcol), amount);

        snapStart("WrappedCollateral_wrap");
        wcol.wrap(brian, amount);
        snapEnd();

        vm.stopPrank();

        vm.startPrank(brian);

        snapStart("WrappedCollateral_unwrap");
        wcol.unwrap(alice, amount);
        snapEnd();

        vm.stopPrank();
    }
}
