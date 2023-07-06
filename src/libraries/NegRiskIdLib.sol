// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @title NegRiskIdLib
/// @author Mike Shrieve (mike@polymarket.com)
library NegRiskIdLib {
    bytes32 private constant MASK = bytes32(type(uint256).max) << 8;

    function getMarketId(address _oracle, bytes memory _data) internal pure returns (bytes32) {
        return keccak256(abi.encode(_oracle, _data)) & MASK;
    }

    function getMarketId(bytes32 _questionId) internal pure returns (bytes32) {
        return _questionId & MASK;
    }

    function getQuestionId(bytes32 _marketId, uint8 _outcomeIndex) internal pure returns (bytes32) {
        unchecked {
            return bytes32(uint256(_marketId) + _outcomeIndex);
        }
    }

    function getQuestionIndex(bytes32 _questionId) internal pure returns (uint8) {
        return uint8(uint256(_questionId));
    }
}
