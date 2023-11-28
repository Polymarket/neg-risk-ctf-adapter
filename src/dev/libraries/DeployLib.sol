// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {vm} from "./Vm.sol";

library DeployLib {
    function _deployCode(string memory _what) internal returns (address addr) {
        return _deployCode(_what, "");
    }

    function _deployCode(string memory _what, bytes memory _args) internal returns (address addr) {
        bytes memory bytecode = abi.encodePacked(vm.getCode(_what), _args);
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }

    function deployConditionalTokens() internal returns (address) {
        address deployment = _deployCode("artifacts/ConditionalTokens.json");
        vm.label(deployment, "ConditionalTokens");
        return deployment;
    }

    function deployUmaCtfAdapter(address _ctf, address _finder) internal returns (address) {
        address deployment = _deployCode("artifacts/UmaCtfAdapter.json", abi.encode(_ctf, _finder));
        vm.label(deployment, "UmaCtfAdapter");
        return deployment;
    }

    function deployNegRiskAdapter(address _ctf, address _collateral, address _vault) internal returns (address) {
        address deployment =
            _deployCode("out/NegRiskAdapter.sol/NegRiskAdapter.json", abi.encode(_ctf, _collateral, _vault));
        vm.label(deployment, "NegRiskAdapter");
        return deployment;
    }

    function deployNegRiskCtfExchange(
        address _collateral,
        address _negRiskAdapter,
        address _ctf,
        address _proxyFactory,
        address _safeFactory
    ) internal returns (address) {
        address deployment = _deployCode(
            "out/NegRiskCtfExchange.sol/NegRiskCtfExchange.json",
            abi.encode(_collateral, _ctf, _negRiskAdapter, _proxyFactory, _safeFactory)
        );
        vm.label(deployment, "NegRiskCtfExchange");
        return deployment;
    }

    function deployNegRiskFeeModule(address _negRiskCtfExchange, address _negRiskAdapter, address _ctf)
        internal
        returns (address)
    {
        address deployment = _deployCode(
            "out/NegRiskFeeModule.sol/NegRiskFeeModule.json", abi.encode(_negRiskCtfExchange, _negRiskAdapter, _ctf)
        );
        vm.label(deployment, "NegRiskFeeModule");
        return deployment;
    }

    function deployFeeModule(address _negRiskCtfExchange) internal returns (address) {
        bytes memory args = abi.encode(_negRiskCtfExchange);
        address deployment = _deployCode("out/FeeModule.sol/FeeModule.json", args);
        vm.label(deployment, "NegRiskFeeModule");
        return deployment;
    }
}
