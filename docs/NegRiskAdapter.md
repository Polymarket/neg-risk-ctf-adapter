# NegRiskAdapter

`NegRiskAdapter` provides an adapter interface for the Gnosis Conditional Tokens Framework (CTF) which allows users to _convert_ collections of NO tokens in mutually-exclusive binary markets into a corresponding position of YES tokens and collateral.

In this contract, _markets_ refer to collections of mutually-exclusive binary conditions, and _questions_ (or their corresponding _positions_) refer to the individual conditions themselves.

## Constructor

Deploys the ERC20 Wrapped Collateral contract which collateralizes all Neg Risk markets and positions.
Approves the CTF to transfer wrapped collateral.
Approves wrapped collateral to transfer collateral.

### Parameters

```[solidity]
address _ctf
address _collateral
address _vault
```

## `splitPosition`

Splits collateral into complete sets of YES and NO tokens.

Wrapped collateral is minted to collateralize the tokens.

### Parameters

```[solidity]
address _conditionId,
uint256 _amount
```

Note: Overloaded with a version with a signature matching the equivalent function on the CTF. This ensures that the exchange can be used with this contract without modification.

## `mergePositions`

Merges complete sets of YES and NO tokens into collateral.

_Unwraps_ the wrapped collateral returned  from the CTF into the original collateral before returning to the user.

### Parameters

```[solidity]
address _conditionId,
uint256 _amount
```

Note: Overloaded with a version with a signature matching the equivalent function on the CTF. This ensures that the exchange can be used with this contract without modification.

## `safeTransferFrom`

Provided to ensure compatibility with contracts that expect to be able to transfer tokens from this contract, e.g., the NegRisk CTFExchange.

In order to transfer tokens this way, the owner must approve this contract _and_ the calling contract.

## `redeemPositions`

Redeems a pair of YES and NO tokens for their underlying collateral, once the question is resolved.

Unwraps the resulting wrapped collateral into the original collateral before returning to the user.

### Parameters

```[solidity]
address _conditionId,
uint256[] _amounts
```

## `convertPositions`

Converts a set of NO tokens in the same market into a corresponding position of YES tokens and collateral.

The user must hold at least `_amount` of each NO token.

If the market has `n` questions, and the user converts `_amount` of `m` NO tokens, the user receive `_amount * (m-1)` collateral and `_amount` each of the complimentary YES tokens.

Supposing that exactly one questions resolves true, these two positions have equivalent final values. In the event that all questions resolve false, the resulting position is worth _less_ than the original position. It is not possible for more than one question to resolve true.

There is an optional `feeRate` market parameter which exists to implement a fee on the conversion. Collected fees are sent to the `vault` address.

It is necessary to synthetically mint wrapped collateral in order to collateralize the resulting YES tokens. Careful bookkeeping ensures that the value of outstanding YES tokens will never exceed the value of collateral in the wrapped collateral contract. In this process, it is necessary to burn NO tokens; they are sent to an uncontrolled burn address.

### Parameters

```[solidity]
bytes32 _marketId
uint256 _indexSet
uint256 _amount
```

## `prepareMarket`

Prepares a negRisk market, initializing the marketId.

### Parameters

```[solidity]
uint256 _feeBips
bytes _metadata
```

## `prepareQuestion`

Prepares a negRisk question, preparing the market if necessary, and updating the market.

Only the creator of the market may prepare a question for that market.

### Parameters

```[solidity]
bytes32 _marketId
bytes _metadata
```

## `reportOutcome`

Reports the outcome of a question, resolving the market. Only the creator of the market can report the outcome.

### Parameters

```[solidity]
bytes32 _questionId
bool _outcome
```
