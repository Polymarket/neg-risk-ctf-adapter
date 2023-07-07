// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {CTHelpers} from "./CTHelpers.sol";

/// @title Helpers
/// @notice Helper functions for the NegRiskAdapter
library Helpers {
    /// @notice Returns the positionIds corresponding to _conditionId
    /// @param _collateral  - the collateral address
    /// @param _conditionId - the conditionId
    /// @return positionIds - length 2 array of position ids
    function positionIds(address _collateral, bytes32 _conditionId) internal view returns (uint256[] memory) {
        uint256[] memory positionIds_ = new uint256[](2);

        // YES
        positionIds_[0] = CTHelpers.getPositionId(_collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 1));
        // NO
        positionIds_[1] = CTHelpers.getPositionId(_collateral, CTHelpers.getCollectionId(bytes32(0), _conditionId, 2));

        return positionIds_;
    }

    /// @notice Returns an array with each element set to the same value
    /// @param _length  - the length of the array
    /// @param _value   - the value of each element
    /// @return values_ - the array of values
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

    /// @notice returns the partition for a binary conditional token
    /// @return partition - the partition [1,2] = [0b01, 0b10]
    function partition() internal pure returns (uint256[] memory) {
        uint256[] memory partition_ = new uint256[](2);
        // YES
        partition_[0] = 1;
        // NO
        partition_[1] = 2;
        return partition_;
    }

    /// @notice returns the payouts for a binary conditional token
    /// @notice payouts are [1,0] if _outcome is true and [0,1] otherwise
    /// @param _outcome - the boolean outcome
    /// @return payouts - the payouts
    function payouts(bool _outcome) internal pure returns (uint256[] memory) {
        uint256[] memory payouts_ = new uint256[](2);
        // YES
        payouts_[0] = _outcome ? 1 : 0;
        // NO
        payouts_[1] = _outcome ? 0 : 1;
        return payouts_;
    }
}
