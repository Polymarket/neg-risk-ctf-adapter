// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MarketData, MarketDataLib} from "src/types/MarketData.sol";

abstract contract MarketDataManager {
    // marketId => marketData
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
                               INITIALIZE
    //////////////////////////////////////////////////////////////*/

    function initializeMarketData(bytes32 _marketId, address _oracle, uint256 _feeBips) internal {
        marketData[_marketId] = MarketDataLib.initialize(_oracle, _feeBips);
    }

    function setMarketData(bytes32 _marketId, MarketData _md) internal {
        marketData[_marketId] = _md;
    }
}
