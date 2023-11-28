// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console, Test, Vm} from "../../../lib/forge-std/src/Test.sol";
import {Side, SignatureType} from "../../../lib/ctf-exchange/src/exchange/libraries/OrderStructs.sol";
import {NegRiskAdapter} from "../../NegRiskAdapter.sol";
import {IConditionalTokens, ICTFExchange, IERC20, IFeeModule} from "../../interfaces/index.sol";
import {AddressLib} from "../../dev/libraries/AddressLib.sol";
import {DeployLib} from "../../dev/libraries/DeployLib.sol";
import {OrderHelper} from "../../dev/OrderHelper.sol";
import {StorageHelper} from "../../dev/StorageHelper.sol";
import {USDC} from "../mock/USDC.sol";

contract NegRiskFeeModuleTestHelper is Test, StorageHelper, OrderHelper {
    address immutable ctf;
    address immutable negRiskAdapter;
    address immutable negRiskCtfExchange;
    address immutable negRiskFeeModule;
    address immutable usdc;

    Vm.Wallet alice;
    Vm.Wallet brian;
    Vm.Wallet carly;
    Vm.Wallet admin;
    Vm.Wallet operator;

    uint256[] partition;

    bytes32 marketId;
    bytes32 questionId;
    bytes32 conditionId;

    uint256 yesPositionId;
    uint256 noPositionId;

    constructor() {
        admin = vm.createWallet("admin");
        operator = vm.createWallet("operator");

        alice = vm.createWallet("alice");
        brian = vm.createWallet("brian");
        carly = vm.createWallet("carly");

        partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;

        vm.startPrank(admin.addr);
        address vault = vm.createWallet("vault").addr;

        ctf = DeployLib.deployConditionalTokens();
        usdc = address(new USDC());

        negRiskAdapter = address(new NegRiskAdapter(ctf, usdc, vault));
        negRiskCtfExchange = DeployLib.deployNegRiskCtfExchange({
            _collateral: usdc,
            _ctf: ctf,
            _negRiskAdapter: negRiskAdapter,
            _proxyFactory: address(0),
            _safeFactory: address(0)
        });
        negRiskFeeModule = DeployLib.deployNegRiskFeeModule(negRiskCtfExchange, negRiskAdapter, ctf);

        /// NEG RISK ADAPTER
        // allow negRiskCtfExchange to transfer using the NegRiskAdapter
        NegRiskAdapter(negRiskAdapter).addAdmin(negRiskCtfExchange);
        // allow negRiskFeeModule to transfer using the NegRiskAdapter
        NegRiskAdapter(negRiskAdapter).addAdmin(negRiskFeeModule);

        /// NEG RISK CTF EXCHANGE
        // set operator as operator
        ICTFExchange(negRiskCtfExchange).addOperator(operator.addr);
        // set fee module as operator
        ICTFExchange(negRiskCtfExchange).addOperator(negRiskFeeModule);
        /// NEG RISK FEE MODULE
        IFeeModule(negRiskFeeModule).addAdmin(operator.addr);

        vm.stopPrank();
    }
}
