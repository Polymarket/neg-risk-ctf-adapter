// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CTHelpers} from "./CTHelpers.sol";

library Helpers {
    function positionIds(address _collateral, bytes32 _conditionId) internal view returns (uint256[] memory) {
        uint256[] memory positionIds_ = new uint256[](2);

        positionIds_[0] = CTHelpers.getPositionId(_collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 1));
        positionIds_[1] = CTHelpers.getPositionId(_collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 2));

        return positionIds_;
    }

    function values(uint256 _length, uint256 _value) internal pure returns (uint256[] memory) {
        uint256[] memory values_ = new uint256[](_length);
        uint256 i;

        while (i < _length) {
            values_[i] = _value;

            unchecked {
                ++i;
            }
        }
        return values_;
    }

    function partition() internal pure returns (uint256[] memory) {
        uint256[] memory partition_ = new uint256[](2);
        partition_[0] = 1;
        partition_[1] = 2;
        return partition_;
    }

    function payouts(bool _outcome) internal pure returns (uint256[] memory) {
        uint256[] memory payouts_ = new uint256[](2);
        payouts_[0] = _outcome ? 1 : 0;
        payouts_[1] = _outcome ? 0 : 1;
        return payouts_;
    }
}
