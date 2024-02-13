# neg-risk-ctf-adapter

## Contracts

- The `NegRiskAdapter` provides an adapter interface for the Gnosis Conditional Tokens Framework (CTF) which allows users to _convert_ collections of NO tokens in mutually-exclusive binary markets into a corresponding position of YES tokens and collateral. [Notes](./NegRiskAdapter.md).
- The `NegRiskOperator` is designed to allow admin accounts to prepare questions and markets, as well as to integrate with resolution sources. [Notes](./NegRiskOperator.md).
- The `Vault` is a permmissioned vault for holding USDC and Yes tokens which are collected as fees from users who choose to convert NO positions, given a positive fee rate.
- The `NegRiskCtfExchange` is a lightweight fork of Polymarket's exchange contract: (https://github.com/Polymarket/ctf-exchange)[https://github.com/Polymarket/ctf-exchange]. It is designed to be enable trading with Polymarket's CLOB in NegRisk markets.
- The `NegRiskFeeModule` is a lightweight fork of Polymarket's fee module: (https://github.com/Polymarket/exchange-fee-module)[https://github.com/Polymarket/exchange-fee-module]. It is designed to be used with the NegRiskCtfExchange.
- The `WrappedCollateral` contract is an ERC20 which wraps collateral (namely USDC) and which is used to collateralize all Neg Risk markets and positions.

## Modules

- `MarketDataManager` is a module managing market state. Each market's state is encapsulated in a single bytes32 `MarketData` value. Used by the NegRiskCtfAdapter. [Notes](./MarketDataManager.md).
- `Auth` is a generic autorization module with multiple owners.

## Libraries

- `CTHelpers` is a library for working with the Gnosis Conditional Tokens Framework (CTF).
- `Helpers` is an internal library for preparing arrays of values for use in the NegRiskAdapter.

## Types

- `MarketData` is an internal data type wrapping a `bytes32` representing the state of a market.
