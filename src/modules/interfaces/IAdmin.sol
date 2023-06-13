// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IAuth, IAuthEE} from "./IAuth.sol";

interface IAdminEE is IAuthEE {
    error QuestionIsPaused();
    error QuestionIsNotPaused();
    error SafetyPeriodNotPassed();

    error ContractIsGloballyPaused();
    error ContractIsNotGloballyPaused();

    /// @notice Emitted when a question is paused by an authorized user
    event QuestionPaused(bytes32 indexed questionID);

    /// @notice Emitted when a question is unpaused by an authorized user
    event QuestionUnpaused(bytes32 indexed questionID);

    event ContractGloballyPaused();
    event ContractGloballyUnpaused();
}

interface IAdmin is IAuth, IAdminEE {}
