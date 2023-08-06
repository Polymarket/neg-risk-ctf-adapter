// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {MarketData, MarketDataLib} from "src/types/MarketData.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";

interface IMarketStateManagerEE {
    error IndexOutOfBounds();
    error OnlyOracle();
    error MarketNotPrepared();
    error MarketAlreadyPrepared();
    error MarketAlreadyDetermined();
    error FeeBipsOutOfBounds();
}

/// @title MarketStateManager
/// @notice Manages market state on behalf of the NegRiskAdapter
/// @author Mike Shrieve(mike@polymarket.com)
abstract contract MarketStateManager is IMarketStateManagerEE {
    mapping(bytes32 _marketId => MarketData) internal marketData;

    /*//////////////////////////////////////////////////////////////
                                GETTERS
    //////////////////////////////////////////////////////////////*/

    function getMarketData(bytes32 _marketId) public view returns (MarketData) {
        return marketData[_marketId];
    }

    function getOracle(bytes32 _marketId) external view returns (address) {
        return marketData[_marketId].oracle();
    }

    function getQuestionCount(bytes32 _marketId) external view returns (uint256) {
        return marketData[_marketId].questionCount();
    }

    function getDetermined(bytes32 _marketId) external view returns (bool) {
        return marketData[_marketId].determined();
    }

    function getResult(bytes32 _marketId) external view returns (uint256) {
        return marketData[_marketId].result();
    }

    function getFeeBips(bytes32 _marketId) external view returns (uint256) {
        return marketData[_marketId].feeBips();
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepares market data
    /// @notice The market id depends on the oracle address, feeBips, and market metadata
    /// @param _feeBips  - feeBips out of 10_000
    /// @param _metadata - market metadata
    /// @return marketId - the market id
    function _prepareMarket(uint256 _feeBips, bytes memory _metadata) internal returns (bytes32 marketId) {
        address oracle = msg.sender;
        marketId = NegRiskIdLib.getMarketId(oracle, _feeBips, _metadata);
        MarketData md = marketData[marketId];

        if (md.oracle() != address(0)) revert MarketAlreadyPrepared();
        if (_feeBips > 10_000) revert FeeBipsOutOfBounds();

        marketData[marketId] = MarketDataLib.initialize(oracle, _feeBips);
    }

    /// @notice Prepares a new question for the given market
    /// @param _marketId   - the market for which to prepare a new question
    /// @return questionId - the resulting question id
    /// @return index      - the resulting question index
    function _prepareQuestion(bytes32 _marketId) internal returns (bytes32 questionId, uint256 index) {
        MarketData md = marketData[_marketId];
        address oracle = marketData[_marketId].oracle();

        if (oracle == address(0)) revert MarketNotPrepared();
        if (oracle != msg.sender) revert OnlyOracle();

        index = md.questionCount();
        questionId = NegRiskIdLib.getQuestionId(_marketId, uint8(index));
        marketData[_marketId] = md.incrementQuestionCount();
    }

    /// @notice Reports the outcome of a question
    /// @notice State is only modified if the outcome is true
    /// @notice Reverts if the market is not prepared
    /// @notice Reverts if msg.sender is not the market's oracle
    /// @notice Reverts if the question index is out of bounds
    /// @notice Reverts if the outcome is true, and the market has already been determined
    function _reportOutcome(bytes32 _questionId, bool _outcome) internal {
        bytes32 marketId = NegRiskIdLib.getMarketId(_questionId);
        uint256 questionIndex = NegRiskIdLib.getQuestionIndex(_questionId);

        MarketData data = marketData[marketId];
        address oracle = data.oracle();

        if (oracle == address(0)) revert MarketNotPrepared();
        if (oracle != msg.sender) revert OnlyOracle();
        if (questionIndex >= data.questionCount()) revert IndexOutOfBounds();

        if (_outcome == true) {
            if (data.determined()) revert MarketAlreadyDetermined();
            marketData[marketId] = data.determine(questionIndex);
        }
    }
}
