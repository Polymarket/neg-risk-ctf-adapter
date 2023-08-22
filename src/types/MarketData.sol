// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/// @notice the MarketData user-defined type, a zero-cost abstraction over bytes32
type MarketData is bytes32;

// md[0] = questionCount
// md[1] = determined
// md[2] = result
// md[3:4] = feeBips
// md[12:32] = oracle

using MarketDataLib for MarketData global;

/// @title MarketDataLib
/// @notice Library for dealing with the MarketData user-defined bytes32 type
/// @author Mike Shrieve (mike@polymarket.com)
library MarketDataLib {
    error DeterminedFlagAlreadySet();

    /// @notice used to increment the questionCount
    uint256 constant INCREMENT = uint256(bytes32(bytes1(0x01)));

    /// @notice extracts the oracle address from MarketData
    /// @return oracle - the address of the oracle
    function oracle(MarketData _data) internal pure returns (address) {
        return address(uint160(uint256(MarketData.unwrap(_data))));
    }

    /// @notice extracts the questionCount from MarketData
    /// @return questionCount - the number of questions in the market
    function questionCount(MarketData _data) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_data)[0]));
    }

    /// @notice increments the questionCount
    /// @notice does _not_ check to see if the questionCount is already at the maximum value
    /// @return marketData - the modified MarketData
    function incrementQuestionCount(MarketData _data) internal pure returns (MarketData) {
        bytes32 data = MarketData.unwrap(_data);
        data = bytes32(uint256(data) + INCREMENT);
        return MarketData.wrap(data);
    }

    /// @notice extracts the determined flag from MarketData
    /// @return determined - true if the market has been determined, i.e. if one of the questions was resolved true
    function determined(MarketData _data) internal pure returns (bool) {
        return MarketData.unwrap(_data)[1] == 0x00 ? false : true;
    }

    /// @notice marks the market as determined
    /// @param _result - the result of the market, i.e., the index of the question that was resolved true
    /// @return marketData - the modified MarketData
    function determine(MarketData _data, uint256 _result) internal pure returns (MarketData) {
        bytes32 data = MarketData.unwrap(_data);

        if (data[1] != 0x00) revert DeterminedFlagAlreadySet();
        data |= bytes32(bytes1(0x01)) >> 8;
        data |= bytes32(bytes1(uint8(_result))) >> 16;

        return MarketData.wrap(data);
    }

    /// @notice initializes the MarketData type
    /// @param _oracle - the address of the oracle
    /// @param _feeBips - the feeBips, out of 10_000
    /// @return marketData - the initialized MarketData
    function initialize(address _oracle, uint256 _feeBips) internal pure returns (MarketData) {
        bytes32 data;
        data |= bytes32(bytes2(uint16(_feeBips))) >> 24;
        data |= bytes32(uint256(uint160(_oracle)));
        return MarketData.wrap(data);
    }

    /// @notice extracts the result from MarketData, i.e., the index of the question that was resolved true
    /// @notice if the market has not been determined, returns zero
    /// @return result - the index of the question that was resolved true, or zero
    function result(MarketData _data) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_data)[2]));
    }

    /// @notice extracts the feeBips from MarketData, out of 10_000
    /// @return feeBips - the feeBips
    function feeBips(MarketData _data) internal pure returns (uint256) {
        return uint256(uint16(bytes2(MarketData.unwrap(_data) << 24)));
    }
}
