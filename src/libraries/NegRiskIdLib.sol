// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title NegRiskIdLib
/// @notice Functions for the NegRiskAdapter Market and QuestionIds
/// @notice MarketIds are the keccak256 hash of the oracle, feeBips, and metadata, with the final 8 bits set to 0
/// @notice QuestionIds share the first 31 bytes with their corresponding MarketId, and the final byte consists of the
/// questionIndex
/// @author Mike Shrieve (mike@polymarket.com)
library NegRiskIdLib {
    bytes32 private constant MASK = bytes32(type(uint256).max) << 8;

    /// @notice Returns the MarketId for a given oracle, feeBips, and metadata
    /// @param _oracle   - the oracle address
    /// @param _feeBips  - the feeBips, out of 10_000
    /// @param _metadata - the market metadata
    /// @return marketId - the marketId
    function getMarketId(address _oracle, uint256 _feeBips, bytes memory _metadata) internal pure returns (bytes32) {
        return keccak256(abi.encode(_oracle, _feeBips, _metadata)) & MASK;
    }

    /// @notice Returns the MarketId for a given QuestionId
    /// @param _questionId - the questionId
    /// @return marketId   - the marketId
    function getMarketId(bytes32 _questionId) internal pure returns (bytes32) {
        return _questionId & MASK;
    }

    /// @notice Returns the QuestionId for a given MarketId and questionIndex
    /// @param _marketId      - the marketId
    /// @param _questionIndex - the questionIndex
    /// @return questionId    - the questionId
    function getQuestionId(bytes32 _marketId, uint8 _questionIndex) internal pure returns (bytes32) {
        unchecked {
            return bytes32(uint256(_marketId) + _questionIndex);
        }
    }

    /// @notice Returns the questionIndex for a given QuestionId
    /// @param _questionId - the questionId
    /// @return questionIndex - the questionIndex
    function getQuestionIndex(bytes32 _questionId) internal pure returns (uint8) {
        return uint8(uint256(_questionId));
    }
}
