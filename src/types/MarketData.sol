// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

type MarketData is bytes32;

using MarketDataLib for MarketData global;

// MarketData

// md[0] = questionCount
// md[1] = determined
// md[2] = result
// md[3:4] = feeBips
// md[12:32] = oracle

library MarketDataLib {
    uint256 constant INCREMENT = uint256(bytes32(bytes1(0x01)));

    function oracle(MarketData _data) internal pure returns (address) {
        return address(uint160(uint256(MarketData.unwrap(_data))));
    }

    function questionCount(MarketData _data) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_data)[0]));
    }

    function incrementQuestionCount(MarketData _data) internal pure returns (MarketData) {
        bytes32 data = MarketData.unwrap(_data);
        data = bytes32(uint256(data) + INCREMENT);
        return MarketData.wrap(data);
    }

    function determined(MarketData _data) internal pure returns (bool) {
        return MarketData.unwrap(_data)[1] == 0x00 ? false : true;
    }

    function determine(MarketData _data, uint256 _result) internal pure returns (MarketData) {
        bytes32 data = MarketData.unwrap(_data);

        if (data[1] != 0x00) revert();
        data |= bytes32(bytes1(0x01)) >> 8;
        data |= bytes32(bytes1(uint8(_result))) >> 16;

        return MarketData.wrap(data);
    }

    function initialize(address _oracle, uint256 _feeBips) internal pure returns (MarketData) {
        bytes32 data;
        data |= bytes32(bytes2(uint16(_feeBips))) >> 24;
        data |= bytes32(uint256(uint160(_oracle)));
        return MarketData.wrap(data);
    }

    function result(MarketData _data) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_data)[2]));
    }

    function feeBips(MarketData _data) internal pure returns (uint256) {
        return uint256(uint16(bytes2(MarketData.unwrap(_data) << 24)));
    }
}
