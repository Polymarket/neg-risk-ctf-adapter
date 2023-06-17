// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {console} from "forge-std/Test.sol";

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
    bytes32 constant ORACLE_MASK = bytes32(uint256(type(uint160).max));

    function oracle(MarketData _d) internal pure returns (address) {
        return address(uint160(uint256(MarketData.unwrap(_d))));
    }

    function questionCount(MarketData _d) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_d)[0]));
    }

    function incrementQuestionCount(
        MarketData _d
    ) internal pure returns (MarketData) {
        bytes32 d = MarketData.unwrap(_d);
        d = bytes32(uint256(d) + INCREMENT);
        return MarketData.wrap(d);
    }

    function determined(MarketData _d) internal pure returns (bool) {
        return MarketData.unwrap(_d)[1] == 0x00 ? false : true;
    }

    function determine(
        MarketData _d,
        uint256 _result
    ) internal pure returns (MarketData) {
        bytes32 d = MarketData.unwrap(_d);

        if (d[1] != 0x00) revert();
        d |= bytes32(bytes1(0x01)) >> 8;
        d |= bytes32(bytes1(uint8(_result))) >> 16;

        return MarketData.wrap(d);
    }

    function initialize(
        address _oracle,
        uint256 _feeBips
    ) internal pure returns (MarketData) {
        bytes32 d;
        d |= bytes32(bytes2(uint16(_feeBips))) >> 24;
        d |= bytes32(uint256(uint160(_oracle)));
        return MarketData.wrap(d);
    }

    function result(MarketData _d) internal pure returns (uint256) {
        return uint256(uint8(MarketData.unwrap(_d)[2]));
    }

    function feeBips(MarketData _d) internal view returns (uint256) {
        console.logBytes32(MarketData.unwrap(_d) << 24);
        return uint256(uint16(bytes2(MarketData.unwrap(_d) << 24)));
    }
}
