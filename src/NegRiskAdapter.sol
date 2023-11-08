// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC1155TokenReceiver} from "lib/solmate/src/tokens/ERC1155.sol";
import {ERC20} from "lib/solmate/src/tokens/ERC20.sol";
import {SafeTransferLib} from "lib/solmate/src/utils/SafeTransferLib.sol";

import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {MarketData, MarketStateManager, IMarketStateManagerEE} from "src/modules/MarketDataManager.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";
import {Helpers} from "src/libraries/Helpers.sol";
import {NegRiskIdLib} from "src/libraries/NegRiskIdLib.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {Auth} from "src/modules/Auth.sol";
import {IAuthEE} from "src/modules/interfaces/IAuth.sol";

/// @title INegRiskAdapterEE
/// @notice NegRiskAdapter Errors and Events
interface INegRiskAdapterEE is IMarketStateManagerEE, IAuthEE {
    error InvalidIndexSet();
    error LengthMismatch();
    error UnexpectedCollateralToken();
    error NoConvertiblePositions();
    error NotApprovedForAll();

    event MarketPrepared(bytes32 indexed marketId, address indexed oracle, uint256 feeBips, bytes data);
    event QuestionPrepared(bytes32 indexed marketId, bytes32 indexed questionId, uint256 index, bytes data);
    event OutcomeReported(bytes32 indexed marketId, bytes32 indexed questionId, bool outcome);
    event PositionSplit(address indexed stakeholder, bytes32 indexed conditionId, uint256 amount);
    event PositionsMerge(address indexed stakeholder, bytes32 indexed conditionId, uint256 amount);
    event PositionsConverted(
        address indexed stakeholder, bytes32 indexed marketId, uint256 indexed indexSet, uint256 amount
    );
    event PayoutRedemption(address indexed redeemer, bytes32 indexed conditionId, uint256[] amounts, uint256 payout);
}

/// @title NegRiskAdapter
/// @notice Adapter for the CTF enabling the linking of a set binary markets where only one can resolve true
/// @notice The adapter prevents more than one question in the same multi-outcome market from resolving true
/// @notice And the adapter allows for the conversion of a set of no positions, to collateral plus the set of
/// complementary yes positions
/// @author Mike Shrieve (mike@polymarket.com)
contract NegRiskAdapter is ERC1155TokenReceiver, MarketStateManager, INegRiskAdapterEE, Auth {
    using SafeTransferLib for ERC20;

    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    IConditionalTokens public immutable ctf;
    ERC20 public immutable col;
    WrappedCollateral public immutable wcol;
    address public immutable vault;

    address public constant NO_TOKEN_BURN_ADDRESS = address(bytes20(bytes32(keccak256("NO_TOKEN_BURN_ADDRESS"))));
    uint256 public constant FEE_DENOMINATOR = 10_000;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _ctf  - ConditionalTokens address
    /// @param _collateral - collateral address
    constructor(address _ctf, address _collateral, address _vault) {
        ctf = IConditionalTokens(_ctf);
        col = ERC20(_collateral);
        vault = _vault;

        wcol = new WrappedCollateral(_collateral, col.decimals());
        // approve the ctf to transfer wcol on our behalf
        wcol.approve(_ctf, type(uint256).max);
        // approve wcol to transfer collateral on our behalf
        col.approve(address(wcol), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                                  IDS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the conditionId for a given questionId
    /// @param _questionId  - the questionId
    /// @return conditionId - the corresponding conditionId
    function getConditionId(bytes32 _questionId) public view returns (bytes32) {
        return CTHelpers.getConditionId(
            address(this), // oracle
            _questionId,
            2 // outcomeCount
        );
    }

    /// @notice Returns the positionId for a given questionId and outcome
    /// @param _questionId  - the questionId
    /// @param _outcome     - the boolean outcome
    /// @return positionId  - the corresponding positionId
    function getPositionId(bytes32 _questionId, bool _outcome) public view returns (uint256) {
        bytes32 collectionId = CTHelpers.getCollectionId(
            bytes32(0),
            getConditionId(_questionId),
            _outcome ? 1 : 2 // 1 (0b01) is yes, 2 (0b10) is no
        );

        uint256 positionId = CTHelpers.getPositionId(address(wcol), collectionId);
        return positionId;
    }

    /*//////////////////////////////////////////////////////////////
                             SPLIT POSITION
    //////////////////////////////////////////////////////////////*/

    /// @notice Splits collateral to a complete set of conditional tokens for a single question
    /// @notice This function signature is the same as the CTF's splitPosition
    /// @param _collateralToken - the collateral token, must be the same as the adapter's collateral token
    /// @param _conditionId - the conditionId for the question
    /// @param _amount - the amount of collateral to split
    function splitPosition(address _collateralToken, bytes32, bytes32 _conditionId, uint256[] calldata, uint256 _amount)
        external
    {
        if (_collateralToken != address(col)) revert UnexpectedCollateralToken();
        splitPosition(_conditionId, _amount);
    }

    /// @notice Splits collateral to a complete set of conditional tokens for a single question
    /// @param _conditionId - the conditionId for the question
    /// @param _amount - the amount of collateral to split
    function splitPosition(bytes32 _conditionId, uint256 _amount) public {
        col.safeTransferFrom(msg.sender, address(this), _amount);
        wcol.wrap(address(this), _amount);
        ctf.splitPosition(address(wcol), bytes32(0), _conditionId, Helpers.partition(), _amount);
        ctf.safeBatchTransferFrom(
            address(this), msg.sender, Helpers.positionIds(address(wcol), _conditionId), Helpers.values(2, _amount), ""
        );

        emit PositionSplit(msg.sender, _conditionId, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                            MERGE POSITIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Merges a complete set of conditional tokens for a single question to collateral
    /// @notice This function signature is the same as the CTF's mergePositions
    /// @param _collateralToken - the collateral token, must be the same as the adapter's collateral token
    /// @param _conditionId - the conditionId for the question
    /// @param _amount - the amount of collateral to merge
    function mergePositions(
        address _collateralToken,
        bytes32,
        bytes32 _conditionId,
        uint256[] calldata,
        uint256 _amount
    ) external {
        if (_collateralToken != address(col)) revert UnexpectedCollateralToken();
        mergePositions(_conditionId, _amount);
    }

    /// @notice Merges a complete set of conditional tokens for a single question to collateral
    /// @param _conditionId - the conditionId for the question
    /// @param _amount - the amount of collateral to merge
    function mergePositions(bytes32 _conditionId, uint256 _amount) public {
        uint256[] memory positionIds = Helpers.positionIds(address(wcol), _conditionId);

        // get conditional tokens from sender
        ctf.safeBatchTransferFrom(msg.sender, address(this), positionIds, Helpers.values(2, _amount), "");
        ctf.mergePositions(address(wcol), bytes32(0), _conditionId, Helpers.partition(), _amount);
        wcol.unwrap(msg.sender, _amount);

        emit PositionsMerge(msg.sender, _conditionId, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                           ERC1155 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function balanceOf(address _owner, uint256 _id) external view returns (uint256) {
        return ctf.balanceOf(_owner, _id);
    }

    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) external view returns (uint256[] memory) {
        return ctf.balanceOfBatch(_owners, _ids);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data)
        external
        onlyAdmin
    {
        if (!ctf.isApprovedForAll(_from, msg.sender)) {
            revert NotApprovedForAll();
        }

        return ctf.safeTransferFrom(_from, _to, _id, _value, _data);
    }

    // function safeBatchTransferFrom(
    //     address _from,
    //     address _to,
    //     uint256[] calldata _ids,
    //     uint256[] calldata _values,
    //     bytes calldata _data
    // ) external onlyAdmin {
    //     if (!ctf.isApprovedForAll(_from, msg.sender)) {
    //         revert NotApprovedForAll();
    //     }

    //     return ctf.safeBatchTransferFrom(_from, _to, _ids, _values, _data);
    // }

    /*//////////////////////////////////////////////////////////////
                            REDEEM POSITION
    //////////////////////////////////////////////////////////////*/

    /// @notice Redeem a set of conditional tokens for collateral
    /// @param _conditionId - conditionId of the conditional tokens to redeem
    /// @param _amounts - amounts of conditional tokens to redeem
    /// _amounts should always have length 2, with the first element being the amount of yes tokens to redeem and the
    /// second element being the amount of no tokens to redeem
    function redeemPositions(bytes32 _conditionId, uint256[] calldata _amounts) public {
        uint256[] memory positionIds = Helpers.positionIds(address(wcol), _conditionId);

        // get conditional tokens from sender
        ctf.safeBatchTransferFrom(msg.sender, address(this), positionIds, _amounts, "");
        ctf.redeemPositions(address(wcol), bytes32(0), _conditionId, Helpers.partition());

        uint256 payout = wcol.balanceOf(address(this));
        if (payout > 0) {
            wcol.unwrap(msg.sender, payout);
        }

        emit PayoutRedemption(msg.sender, _conditionId, _amounts, payout);
    }

    /*//////////////////////////////////////////////////////////////
                            CONVERT POSITIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Convert a set of no positions to the complementary set of yes positions plus collateral proportional to
    /// (# of no positions - 1)
    /// @notice If the market has a fee, the fee is taken from both collateral and the yes positions
    /// @param _marketId - the marketId
    /// @param _indexSet - the set of positions to convert, expressed as an index set where the least significant bit is
    /// the first question (index zero)
    /// @param _amount   - the amount of tokens to convert
    function convertPositions(bytes32 _marketId, uint256 _indexSet, uint256 _amount) external {
        MarketData md = getMarketData(_marketId);
        uint256 questionCount = md.questionCount();

        if (md.oracle() == address(0)) revert MarketNotPrepared();
        if (questionCount <= 1) revert NoConvertiblePositions();
        if (_indexSet == 0) revert InvalidIndexSet();
        if ((_indexSet >> questionCount) > 0) revert InvalidIndexSet();

        // if _amount is 0, return early
        if (_amount == 0) {
            return;
        }

        uint256 index = 0;
        uint256 noPositionCount;

        // count number of no positions
        while (index < questionCount) {
            unchecked {
                if ((_indexSet & (1 << index)) > 0) {
                    ++noPositionCount;
                }
                ++index;
            }
        }

        uint256 yesPositionCount = questionCount - noPositionCount;
        uint256[] memory noPositionIds = new uint256[](noPositionCount);
        uint256[] memory yesPositionIds = new uint256[](yesPositionCount);
        uint256[] memory accumulatedNoPositionIds = new uint256[](yesPositionCount);

        // mint the amount of wcol required
        wcol.mint(yesPositionCount * _amount);

        // populate noPositionIds and yesPositionIds
        // split yes positions
        {
            uint256 noIndex;
            uint256 yesIndex;
            index = 0;

            while (index < questionCount) {
                bytes32 questionId = NegRiskIdLib.getQuestionId(_marketId, uint8(index));

                if ((_indexSet & (1 << index)) > 0) {
                    // NO
                    noPositionIds[noIndex] = getPositionId(questionId, false);

                    unchecked {
                        ++noIndex;
                    }
                } else {
                    // YES
                    yesPositionIds[yesIndex] = getPositionId(questionId, true);
                    accumulatedNoPositionIds[yesIndex] = getPositionId(questionId, false);

                    // split position to get yes and no tokens
                    // the no tokens will be discarded
                    _splitPosition(getConditionId(questionId), _amount);

                    unchecked {
                        ++yesIndex;
                    }
                }
                unchecked {
                    ++index;
                }
            }
        }

        // transfer the caller's no tokens _and_ accumulated no tokens to the burn address
        // these must never be redeemed
        {
            ctf.safeBatchTransferFrom(
                msg.sender, NO_TOKEN_BURN_ADDRESS, noPositionIds, Helpers.values(noPositionIds.length, _amount), ""
            );
            ctf.safeBatchTransferFrom(
                address(this),
                NO_TOKEN_BURN_ADDRESS,
                accumulatedNoPositionIds,
                Helpers.values(yesPositionCount, _amount),
                ""
            );
        }

        uint256 feeAmount = (_amount * md.feeBips()) / FEE_DENOMINATOR;
        uint256 amountOut = _amount - feeAmount;

        if (noPositionIds.length > 1) {
            // collateral out is always proportional to the number of no positions minus 1
            uint256 multiplier = noPositionIds.length - 1;
            // transfer collateral fees to vault
            if (feeAmount > 0) {
                wcol.release(vault, multiplier * feeAmount);
            }
            // transfer collateral to sender
            wcol.release(msg.sender, multiplier * amountOut);
        }

        if (yesPositionIds.length > 0) {
            if (feeAmount > 0) {
                // transfer yes token fees to vault
                ctf.safeBatchTransferFrom(
                    address(this), vault, yesPositionIds, Helpers.values(yesPositionIds.length, feeAmount), ""
                );
            }

            // transfer yes tokens to sender
            ctf.safeBatchTransferFrom(
                address(this), msg.sender, yesPositionIds, Helpers.values(yesPositionIds.length, amountOut), ""
            );
        }

        emit PositionsConverted(msg.sender, _marketId, _indexSet, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepare a multi-outcome market
    /// @param _feeBips  - the fee for the market, out of 10_000
    /// @param _metadata     - metadata for the market
    /// @return marketId - the marketId
    function prepareMarket(uint256 _feeBips, bytes calldata _metadata) external returns (bytes32) {
        bytes32 marketId = _prepareMarket(_feeBips, _metadata);

        emit MarketPrepared(marketId, msg.sender, _feeBips, _metadata);

        return marketId;
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    /// @notice Prepare a question for a given market
    /// @param _marketId   - the id of the market for which to prepare the question
    /// @param _metadata   - the question metadata
    /// @return questionId - the id of the resulting question
    function prepareQuestion(bytes32 _marketId, bytes calldata _metadata) external returns (bytes32) {
        (bytes32 questionId, uint256 questionIndex) = _prepareQuestion(_marketId);
        bytes32 conditionId = getConditionId(questionId);

        // check to see if the condition has already been prepared on the ctf
        if (ctf.getOutcomeSlotCount(conditionId) == 0) {
            ctf.prepareCondition(address(this), questionId, 2);
        }

        emit QuestionPrepared(_marketId, questionId, questionIndex, _metadata);

        return questionId;
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT OUTCOME
    //////////////////////////////////////////////////////////////*/

    /// @notice Report the outcome of a question
    /// @param _questionId - the questionId to report
    /// @param _outcome    - the outcome of the question
    function reportOutcome(bytes32 _questionId, bool _outcome) external {
        _reportOutcome(_questionId, _outcome);

        ctf.reportPayouts(_questionId, Helpers.payouts(_outcome));

        emit OutcomeReported(NegRiskIdLib.getMarketId(_questionId), _questionId, _outcome);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    /// @dev internal function to avoid stack too deep in convertPositions
    function _splitPosition(bytes32 _conditionId, uint256 _amount) internal {
        ctf.splitPosition(address(wcol), bytes32(0), _conditionId, Helpers.partition(), _amount);
    }
}
