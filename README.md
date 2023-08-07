# Polymarket Multi-Outcome Markets

The contracts in this repository are designed to unify mutually exclusive binary markets into a single multi-outcome market structure. By mutually exclusive binary markets, we mean a set of binary YES/NO of which one and only one will resolve true. The canonical example is a set of markets each representing a candidate in a particular political election, where only one can win. Each component binary market is a YES/NO market for a particular candidate. The fact that only one candidate can win guarantees that there are certain equivalancies amongst certain sets of positions.

As an example, consider an election with candidates A, B, and C. For each candidate there is a binary YES/NO market, and exactly one candidate will win, i.e., exactly one market will resolve YES, and the rest NO. Consider a position consisting of 1 NO A and 1 NO B.
If A wins, the position is worth 1 USDC. If B wins, the position is again worth 1 USDC. If C wins, the position is worth 2 USDC, as both NO tokens are redeemable for 1 USDC each. We can see that the position is equivalent to 1 USDC and 1 YES C, as the value of the two positions is equal in all three cases. The NegRiskAdapter is designed precisely to allow a position of 1 or more NO tokens to be converted to the equivalent position of YES tokens plus some amount of USDC.

The underlying binary markets are implemented using Gnosis’s Conditional Tokens contracts: https://github.com/gnosis/conditional-tokens-contracts. Once collateral is split into position tokens, there are only two ways to recover it, either by merging complete sets, or by redeeming positions after resolution. So, in order to allow USDC to be released as part of a conversion from a NO position to a YES position, we wrap USDC into WrappedCollateral, which is then used to collateralize all underlying markets. This enables the NegRiskAdapter to manage USDC separately from the ConditionalTokens contract.

The NegRiskOperator is designed to allow admin accounts to prepare questions and markets, as well as to integrate with resolution sources.

The Vault holds USDC and Yes tokens which are collected as fees from users who choose to convert NO positions, given a positive fee rate.

## Use with the UmaCtfAdapter

The NegRiskOperator and NegRiskAdapter are designed to be used with the [UmaCtfAdapter](https://github.com/Polymarket/uma-ctf-adapter), or any oracle with the same interface.
A dedicated UmaCtfAdapter will need to be deployed with the UmaCtfAdapter's `ctf` set to the address of the NegRiskAdapter, and the NegRiskOperator's `oracle` set to the address of the UmaCtfAdapter.
Note that the UmaCtfAdapter can return `[1,1]` as a possible outcome, which is not a valid outcome for the NegRiskAdapter. The NegRiskAdapter will revert if it receives this outcome. It is important that markets/questions are chosen carefully so that this outcome is not possible.
