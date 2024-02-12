# NegRiskOperator

The NegRiskOperator is a permissioned controller for interacting with the NegRiskAdapter. The NegRiskOperator serves as the creator and maintainer for Polymarket's neg risk markets and questions.

The admin may flag individual questions, which will prevent them from resolving normally. Additionally, flagged questions may be _emergency resolved_ manually by the admin, after a one hour delay.

## Constuctor

Sets the immutable value of the NegRiskAdapter.

### Parameters

```[solidity]
address _nrAdapter
```

## `setOracle`

Set the value of the oracle resolution source for all neg risk markets. Reverts if already set to a non-zero value.

### Parameters

```[solidity]
address _oracle
```

## `prepareMarket`

Proxies the NegRisk `prepareMarket` function. The result is that the NegRiskOperator is the creator of the market, and has the ability to prepare and resolve questions for the market.

### Parameters

```[solidity]
uint256 _feeBips
bytes _data
```

## `prepareQuestion`

Proxies the NegRisk `prepareQuestion` function.

RequestIds are provided which link an oracle request to the specific question. For NegRisk questions, requestIds always differ from questionIds, and the request must be made specifically _before_ the question is prepared.

If the requestId has already been used for some question, the function will revert.

### Parameters

```[solidity]
bytes32 _marketId
bytes _data
bytes32 _requestId
```

## `resolveQuestion`

Resolves a question on the NegRiskAdapter once the oracle has reported the outcome via `reportPayouts`.

There is a one hour delay period which must elapse between the call to `reportPayouts` and the call to `resolveQuestion`. This serves as a safety period in case there is a manipulation of the oracle.

## `reportPayouts`

Receives the result of a question from the oracle. The oracle is expected to respond with a length two array of uint256s, `[1,0]` if yes, `[0,1]` if no. No other payouts are considered valid.

### Parameters

```[solidity]
bytes32 _requestId
uint256[] calldata _payouts
```
