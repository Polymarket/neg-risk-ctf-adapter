// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper} from "src/dev/TestHelper.sol";
import {NegRiskAdapter} from "src/NegRiskAdapter.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";

contract WrappedCollateralTest is TestHelper {
    USDC usdc;
    WrappedCollateral wcol;
    address owner;

    function setUp() public {
        usdc = new USDC();
        owner = _getAndLabelAddress("owner");

        uint8 decimals = usdc.decimals();

        vm.prank(owner);
        wcol = new WrappedCollateral(address(usdc), decimals);
    }

    function test_initialization() public {
        assertEq(wcol.name(), "Wrapped Collateral");
        assertEq(wcol.symbol(), "WC");
        assertEq(wcol.decimals(), usdc.decimals());
        assertEq(wcol.underlying(), address(usdc));
        assertEq(wcol.owner(), owner);
    }

    function test_wrap(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(owner, big);

        vm.prank(owner);
        usdc.approve(address(wcol), small);

        vm.prank(owner);
        wcol.wrap(carly, small);

        assertEq(usdc.balanceOf(owner), big - small);
        assertEq(wcol.balanceOf(carly), small);
        assertEq(usdc.balanceOf(address(wcol)), small);
    }

    function test_unwrap(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(owner, big);

        vm.prank(owner);
        usdc.approve(address(wcol), big);

        vm.prank(owner);
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

        vm.prank(owner);
        wcol.mint(big);

        vm.prank(owner);
        wcol.burn(small);

        assertEq(wcol.balanceOf(owner), big - small);
    }

    function test_wrapAndBurn(uint64 _a, uint64 _b) public {
        uint256 small = uint256(_a);
        uint256 big = uint256(_b) + small;

        usdc.mint(owner, big);

        vm.prank(owner);
        usdc.approve(address(wcol), big);

        vm.prank(owner);
        wcol.wrap(owner, big);

        vm.prank(owner);
        wcol.burn(small);

        assertEq(wcol.balanceOf(owner), big - small);
    }
}
