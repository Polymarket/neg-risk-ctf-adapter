// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {CTHelpers} from "./CTHelpers.sol";

library Helpers {
    function _positionIds(address _collateral, bytes32 _conditionId)
        internal
        view
        returns (uint256[] memory)
    {
        uint256[] memory positionIds = new uint256[](2);

        positionIds[0] = CTHelpers.getPositionId(
            _collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 1)
        );

        positionIds[1] = CTHelpers.getPositionId(
            _collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 2)
        );

        return positionIds;
    }

    function _values(uint256 _length, uint256 _value) internal pure returns (uint256[] memory) {
        uint256[] memory values = new uint256[](_length);
        uint256 i;

        // to-do: we can save gas using assembly here
        // (no index checks)
        while (i < _length) {
            values[i] = _value;
            ++i;
        }
        return values;
    }

    function _partition() internal pure returns (uint256[] memory) {
        uint256[] memory partition = new uint256[](2);
        partition[0] = 1;
        partition[1] = 2;
        return partition;
    }

    function _payouts(bool _outcome) internal pure returns (uint256[] memory) {
        uint256[] memory partition = new uint256[](2);
        partition[0] = _outcome ? 1 : 0;
        partition[1] = _outcome ? 0 : 1;
        return partition;
    }
}
