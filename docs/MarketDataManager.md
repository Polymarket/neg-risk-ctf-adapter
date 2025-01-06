# MarketDataManager

Module managing market state. Each market's state is encapsulated in a single bytes32 `MarketData` value.

## `_prepareMarket`

Stores the initial marketData setting the oracle to `msg.sender` and the feeBips to `_feeBips`.

Returns the deterministic `marketId`.

### Parameters

```[solidity]
uint256 _feeBips
bytes _metadata
```

## `_prepareQuestion`

Prepares a new question for the given market. Returns the resulting questionId and the index of the question in the market.

QuestionIds always agree with their corresponding marketId in all but the last byte. The last byte contains the question index.

### Parameters

```[solidity]
bytes32 _marketId
```

## `_reportOutcome`

Reports the outcome of a question.
Ensure that `msg.sender` is the oracle.

In case the outcome is true, ensures that no questions have already resolved true in the market.

### Parameters

```[solidity]
bytes32 _questionId
bool _outcome
```
