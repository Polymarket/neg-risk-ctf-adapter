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

    function _prepareMarket(uint256 _feeBips, bytes memory _data) internal returns (bytes32 marketId) {
        address oracle = msg.sender;
        marketId = NegRiskIdLib.getMarketId(oracle, _data);
        MarketData md = marketData[marketId];

        if (md.oracle() != address(0)) revert MarketAlreadyPrepared();
        if (_feeBips > 1_00_00) revert FeeBipsOutOfBounds();

        marketData[marketId] = MarketDataLib.initialize(oracle, _feeBips);
    }

    function _prepareQuestion(bytes32 _marketId) internal returns (bytes32 questionId, uint256 index) {
        MarketData md = marketData[_marketId];
        address oracle = marketData[_marketId].oracle();

        if (oracle == address(0)) revert MarketNotPrepared();
        if (oracle != msg.sender) revert OnlyOracle();

        index = md.questionCount();
        questionId = NegRiskIdLib.getQuestionId(_marketId, uint8(index));
        marketData[_marketId] = md.incrementQuestionCount();
    }

    function _reportOutcome(bytes32 _questionId, bool _outcome)
        internal
        returns (bytes32 marketId, uint256 questionIndex)
    {
        marketId = NegRiskIdLib.getMarketId(_questionId);
        questionIndex = NegRiskIdLib.getQuestionIndex(_questionId);

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
