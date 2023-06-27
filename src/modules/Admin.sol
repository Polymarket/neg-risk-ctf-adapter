// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Auth} from "./Auth.sol";
import {IAdmin} from "./interfaces/IAdmin.sol";

/// @title Admin
/// @author Mike Shrieve (mike@polymarket.com)
/// @notice Admin module for pausing and emergency resolution
/// @notice Admins can pause and unpause individual questions,
/// @notice which allows them to emergency resolve the question
/// @notice after a safety period.
/// @notice Admins can also globally paused resolution of all questions,
/// @notice which causes calls to `resolve` to revert.
/// @notice Global pausing _does not_ affect emergency resolution.
abstract contract Admin is Auth, IAdmin {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    /// @notice Emergency resolutions timestamps are zero if a question
    /// @notice is not paused.  Otherwise, the question may be emergency
    /// @notice resolved when the block timestamp is greater than or equal
    /// @notice  to the emergency resolution timestamp.
    mapping(bytes32 => uint256) public emergencyResolutionTimestamps;

    /// @notice True if the contract is globally paused
    bool public isGloballyPaused;

    /// @notice Period after pausing when an admin can not emergency resolve.
    /// @notice After the safety period has passed, the question can be
    /// @notice emergency resolved.
    uint256 public immutable safetyPeriod;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(uint256 _safetyPeriod) {
        safetyPeriod = _safetyPeriod;
    }

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Reverts if the question is paused or if the contract is
    /// @notice globally paused.
    /// @param _questionId - Question ID
    modifier onlyIfUnpaused(bytes32 _questionId) {
        if (isGloballyPaused) revert ContractIsGloballyPaused();
        if (_isPaused(_questionId)) revert QuestionIsPaused();
        _;
    }

    /// @notice Reverts if the question is not individually paused
    /// @notice or if the safety period has not passed.
    /// @param _questionId - Question ID
    modifier onlyIfEmergencyResolutionIsAllowed(bytes32 _questionId) {
        uint256 resolutionTimestamp = emergencyResolutionTimestamps[_questionId];
        if (!_isPaused(_questionId)) revert QuestionIsNotPaused();
        if (block.timestamp < resolutionTimestamp) {
            revert SafetyPeriodNotPassed();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Pause an individual question
    /// @param _questionId - Question ID
    function pause(bytes32 _questionId) external onlyAdmin {
        if (_isPaused(_questionId)) revert QuestionIsPaused();

        emergencyResolutionTimestamps[_questionId] = block.timestamp + safetyPeriod;

        emit QuestionPaused(_questionId);
    }

    /// @notice Unpause an individual question
    /// @param _questionId - Question ID
    function unpause(bytes32 _questionId) external onlyAdmin {
        if (!_isPaused(_questionId)) revert QuestionIsNotPaused();

        emergencyResolutionTimestamps[_questionId] = 0;

        emit QuestionUnpaused(_questionId);
    }

    /// @notice Globally pause all resolutions
    function pauseGlobally() external onlyAdmin {
        if (isGloballyPaused) revert ContractIsGloballyPaused();

        isGloballyPaused = true;

        emit ContractGloballyPaused();
    }

    /// @notice Deactivate global pause
    function unpauseGlobally() external onlyAdmin {
        if (!isGloballyPaused) revert ContractIsNotGloballyPaused();

        isGloballyPaused = false;

        emit ContractGloballyUnpaused();
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns true if the question is paused.
    /// @notice i.e., if the emergency resolution timestamp is non-zero.
    /// @param _questionId - Question ID
    function _isPaused(bytes32 _questionId) internal view returns (bool) {
        return emergencyResolutionTimestamps[_questionId] > 0;
    }
}
