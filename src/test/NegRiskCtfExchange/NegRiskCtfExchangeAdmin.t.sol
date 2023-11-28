// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Test} from "../../../lib/forge-std/src/Test.sol";
import {IConditionalTokens, ICTFExchange, IERC20, IFeeModule, INegRiskAdapter} from "../../interfaces/index.sol";
import {NegRiskFeeModule} from "../../NegRiskFeeModule.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {USDC} from "../mock/USDC.sol";

contract NegRiskFeeModuleAdmin_Test is Test {
    address alice;
    address ctf;
    address usdc;
    address negRiskAdapter;
    address negRiskCtfExchange;

    function setUp() public {
        address vault = vm.createWallet("vault").addr;
        ctf = DeployLib.deployConditionalTokens();
        usdc = address(new USDC());
        negRiskAdapter = DeployLib.deployNegRiskAdapter({_ctf: ctf, _collateral: usdc, _vault: vault});
        negRiskCtfExchange = DeployLib.deployNegRiskCtfExchange({
            _collateral: usdc,
            _ctf: ctf,
            _negRiskAdapter: negRiskAdapter,
            _proxyFactory: address(0),
            _safeFactory: address(0)
        });

        alice = vm.createWallet("alice").addr;
    }

    function test_NegRiskFeeModuleAdmin_initialAdmin(uint256 _id, uint256 _amount) public {
        vm.prank(alice);
        NegRiskFeeModule negRiskFeeModule = new NegRiskFeeModule(negRiskCtfExchange, negRiskAdapter, ctf);

        assertTrue(negRiskFeeModule.isAdmin(address(alice)));
    }
}
