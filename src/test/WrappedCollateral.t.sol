// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "../dev/TestHelper.sol";

import {NegRiskAdapter} from "../NegRiskAdapter.sol";
import {WrappedCollateral} from "../WrappedCollateral.sol";
import {DeployLib} from "../dev/libraries/DeployLib.sol";
import {USDC} from "./mock/USDC.sol";

contract WrappedCollateralTest is TestHelper {
    USDC usdc;
    WrappedCollateral wcol;

    function setUp() public {
        usdc = new USDC();

        uint8 decimals = usdc.decimals();

        vm.prank(alice);
        wcol = new WrappedCollateral(address(usdc), decimals);
    }

    function test_initialization() public {
        assertEq(wcol.name(), "Wrapped Collateral");
        assertEq(wcol.symbol(), "WC");
        assertEq(wcol.decimals(), usdc.decimals());
        assertEq(wcol.underlying(), address(usdc));
        assertEq(wcol.owner(), alice);
    }

    function test_wrap(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(brian, big);

        vm.prank(brian);
        usdc.approve(address(wcol), small);

        vm.prank(brian);
        wcol.wrap(carly, small);

        assertEq(usdc.balanceOf(brian), big - small);
        assertEq(wcol.balanceOf(carly), small);
        assertEq(usdc.balanceOf(address(wcol)), small);
    }

    function test_unwrap(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(brian, big);

        vm.prank(brian);
        usdc.approve(address(wcol), big);

        vm.prank(brian);
        wcol.wrap(brian, big);

        vm.prank(brian);
        wcol.unwrap(carly, small);

        assertEq(usdc.balanceOf(carly), small);
        assertEq(wcol.balanceOf(brian), big - small);
        assertEq(usdc.balanceOf(address(wcol)), big - small);
    }

    function test_mintAndBurn(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        vm.prank(alice);
        wcol.mint(big);

        vm.prank(alice);
        wcol.burn(small);

        assertEq(wcol.balanceOf(alice), big - small);
    }

    function test_wrapAndBurn(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(alice, big);

        vm.prank(alice);
        usdc.approve(address(wcol), big);

        vm.prank(alice);
        wcol.wrap(alice, big);

        vm.prank(alice);
        wcol.burn(small);

        assertEq(wcol.balanceOf(alice), big - small);
    }
}
