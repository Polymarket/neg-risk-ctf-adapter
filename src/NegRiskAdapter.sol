// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {ERC1155TokenReceiver} from "lib/solmate/src/tokens/ERC1155.sol";
import {IERC20} from "src/interfaces/IERC20.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {Helpers} from "src/libraries/Helpers.sol";
import {Admin} from "src/modules/Admin.sol";
import {CTHelpers} from "src/libraries/CTHelpers.sol";
import {MarketData, MarketDataManager} from "src/modules/MarketDataManager.sol";

interface INegRiskAdapterEE {
    error IndexOutOfBounds();
    error OnlyOracle();
    error IndexSetTooSmall();
    error MarketAlreadyPrepared();
    error MarketNotPrepared();
    error LengthMismatch();
    error MarketAlreadyDetermined();
    error FeeBipsOutOfBounds();

    event MarketPrepared(
        bytes32 indexed marketId,
        address indexed oracle,
        bytes data
    );

    event QuestionPrepared(
        bytes32 indexed questionId,
        bytes32 indexed marketId,
        uint256 index,
        address indexed oracle,
        bytes data
    );
}

/// @title CTFWrapper
/// @author Mike Shrieve (mike@polymarket.com)
contract NegRiskAdapter is
    INegRiskAdapterEE,
    ERC1155TokenReceiver,
    MarketDataManager
{
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    IConditionalTokens public immutable ctf;
    IERC20 public immutable col;
    WrappedCollateral public immutable wcol;
    address public immutable vault;

    address public constant noTokenBurnAddress =
        address(bytes20(bytes32(keccak256("NO_TOKEN_BURN_ADDRESS"))));

    uint256 public constant feeDenominator = 1_00_00;

    bytes32 private constant MASK = bytes32(type(uint256).max) << 8;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _ctf  - ConditionalTokens address
    /// @param _collateral - collateral address
    constructor(address _ctf, address _collateral, address _vault) {
        ctf = IConditionalTokens(_ctf);
        col = IERC20(_collateral);
        vault = _vault;

        wcol = new WrappedCollateral(_collateral, col.decimals());

        // approve the ctf to transfer wcol on our behalf
        wcol.approve(_ctf, type(uint256).max);
        col.approve(address(wcol), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                                  IDS
    //////////////////////////////////////////////////////////////*/

    function computeMarketId(
        address _oracle,
        bytes memory _data
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_oracle, _data)) & MASK;
    }

    function computeQuestionId(
        bytes32 _marketId,
        uint256 _outcomeIndex
    ) public pure returns (bytes32) {
        unchecked {
            return bytes32(uint256(_marketId) + _outcomeIndex);
        }
    }

    function getMarketId(bytes32 _questionId) public pure returns (bytes32) {
        return _questionId & MASK;
    }

    function getQuestionIndex(
        bytes32 _questionId
    ) public pure returns (uint256) {
        return uint256(_questionId & ~MASK);
    }

    function computePositionId(
        bytes32 _questionId,
        bool _outcome
    ) public view returns (uint256) {
        bytes32 collectionId = CTHelpers.getCollectionId(
            bytes32(0),
            getConditionId(_questionId),
            _outcome ? 1 : 2 // 1 is yes, 2 is no
        );

        uint256 positionId = CTHelpers.getPositionId(
            address(wcol),
            collectionId
        );

        return positionId;
    }

    /*//////////////////////////////////////////////////////////////
                             SPLIT POSITION
    //////////////////////////////////////////////////////////////*/

    function splitPosition(
        IERC20 _collateralToken,
        bytes32,
        bytes32 _conditionId,
        uint256[] calldata,
        uint256 _amount
    ) external {
        require(
            _collateralToken == IERC20(address(col)),
            "CTFWrapper: collateralToken != collateral"
        );
        splitPosition(_conditionId, _amount);
    }

    function splitPosition(bytes32 _conditionId, uint256 _amount) public {
        col.transferFrom(msg.sender, address(this), _amount);
        wcol.wrap(address(this), _amount);

        ctf.splitPosition(
            IERC20(address(wcol)),
            bytes32(0),
            _conditionId,
            Helpers._partition(),
            _amount
        );

        ctf.safeBatchTransferFrom(
            address(this),
            msg.sender,
            Helpers._positionIds(address(wcol), _conditionId),
            Helpers._values(2, _amount),
            ""
        );
    }

    /*//////////////////////////////////////////////////////////////
                            MERGE POSITIONS
    //////////////////////////////////////////////////////////////*/

    function mergePositions(
        IERC20 collateralToken,
        bytes32,
        bytes32 _conditionId,
        uint256[] calldata,
        uint256 _amount
    ) external {
        require(
            collateralToken == IERC20(address(col)),
            "CTFWrapper: collateralToken != collateral"
        );
        mergePositions(_conditionId, _amount);
    }

    function mergePositions(bytes32 _conditionId, uint256 _amount) public {
        uint256[] memory positionIds = Helpers._positionIds(
            address(wcol),
            _conditionId
        );

        // get conditional tokens from sender
        ctf.safeBatchTransferFrom(
            msg.sender,
            address(this),
            positionIds,
            Helpers._values(2, _amount),
            ""
        );

        ctf.mergePositions(
            IERC20(address(wcol)),
            bytes32(0),
            _conditionId,
            Helpers._partition(),
            _amount
        );

        wcol.unwrap(msg.sender, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                            REDEEM POSITION
    //////////////////////////////////////////////////////////////*/

    function redeemPositions(
        bytes32 _conditionId,
        uint256[] calldata _amounts
    ) public {
        uint256[] memory positionIds = Helpers._positionIds(
            address(wcol),
            _conditionId
        );

        // get conditional tokens from sender
        ctf.safeBatchTransferFrom(
            msg.sender,
            address(this),
            positionIds,
            _amounts,
            ""
        );

        ctf.redeemPositions(
            IERC20(address(wcol)),
            bytes32(0),
            _conditionId,
            Helpers._partition()
        );

        wcol.unwrap(msg.sender, wcol.balanceOf(address(this)));
    }

    /*//////////////////////////////////////////////////////////////
                            CONVERT POSITION
    //////////////////////////////////////////////////////////////*/

    /// @notice _indexSet looks like 0x0000....01101
    /// @notice the lsb is the _first_ question
    function convertPositions(
        bytes32 _marketId,
        uint256 _amount,
        uint256 _indexSet
    ) external {
        MarketData md = getMarketData(_marketId);
        uint256 questionCount = md.questionCount();

        if ((_indexSet >> questionCount) > 0) {
            revert IndexOutOfBounds();
        }

        // to-do: add errors
        if (_indexSet == 0) revert();
        if (_amount == 0) revert();

        uint256[] memory yesPositionIds;
        uint256[] memory noPositionIds;

        wcol.mint(questionCount * _amount);

        {
            uint256[] memory positionIds = new uint256[](questionCount + 1);

            uint256 index;
            uint256 noIndex;
            uint256 yesIndex = questionCount;

            while (index < questionCount) {
                bytes32 questionId = computeQuestionId(_marketId, index);
                if ((_indexSet & (1 << index)) == 1) {
                    // NO
                    positionIds[noIndex] = computePositionId(questionId, false);

                    unchecked {
                        ++noIndex;
                    }
                } else {
                    // YES
                    _splitPosition(getConditionId(questionId), _amount);
                    positionIds[yesIndex] = computePositionId(questionId, true);

                    unchecked {
                        --yesIndex;
                    }
                }
                ++index;
            }

            uint256 yesPositionsLength = questionCount - noIndex;

            assembly {
                noPositionIds := positionIds
                mstore(noPositionIds, noIndex)

                yesPositionIds := add(positionIds, add(noIndex, 0x20))
                mstore(yesPositionIds, yesPositionsLength)
            }
        }

        wcol.burn(noPositionIds.length * _amount);

        {
            ctf.balanceOf(msg.sender, noPositionIds[0]);
            ctf.safeBatchTransferFrom(
                msg.sender,
                noTokenBurnAddress,
                noPositionIds,
                Helpers._values(noPositionIds.length, _amount),
                ""
            );
        }

        uint256 feeAmount = (_amount * md.feeBips()) / 1_00_00;
        uint256 amountOut = _amount - feeAmount;

        // transfer yes tokens to sender
        if (yesPositionIds.length > 0) {
            ctf.safeBatchTransferFrom(
                address(this),
                msg.sender,
                yesPositionIds,
                Helpers._values(yesPositionIds.length, amountOut),
                ""
            );

            ctf.safeBatchTransferFrom(
                address(this),
                vault,
                yesPositionIds,
                Helpers._values(yesPositionIds.length, feeAmount),
                ""
            );
        }

        uint256 multiplier = (noPositionIds.length - 1);

        wcol.release(msg.sender, multiplier * amountOut);
        wcol.release(vault, multiplier * feeAmount);
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    function prepareMarket(
        bytes memory _data,
        uint256 _feeBips
    ) external returns (bytes32) {
        if (_feeBips > 1_00_00) {
            revert FeeBipsOutOfBounds();
        }

        address oracle = msg.sender;
        bytes32 marketId = computeMarketId(oracle, _data);

        MarketData md = getMarketData(marketId);
        if (md.oracle() != address(0)) {
            revert MarketAlreadyPrepared();
        }

        initializeMarket(marketId, oracle, _feeBips);
        emit MarketPrepared(marketId, oracle, _data);

        return marketId;
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    function prepareQuestion(
        bytes32 _marketId,
        bytes memory _data
    ) external returns (bytes32) {
        MarketData md = getMarketData(_marketId);
        address oracle = md.oracle();

        if (oracle == address(0)) {
            revert MarketNotPrepared();
        }

        if (oracle != msg.sender) {
            revert OnlyOracle();
        }

        uint256 index = md.questionCount();
        bytes32 questionId = computeQuestionId(_marketId, index);

        setMarketData(_marketId, md.incrementQuestionCount());
        ctf.prepareCondition(address(this), questionId, 2);

        emit QuestionPrepared(questionId, _marketId, index, oracle, _data);

        return questionId;
    }

    /*//////////////////////////////////////////////////////////////
                             REPORT OUTCOME
    //////////////////////////////////////////////////////////////*/

    function reportOutcome(bytes32 _questionId, bool _outcome) external {
        bytes32 marketId = getMarketId(_questionId);
        uint256 questionIndex = getQuestionIndex(_questionId);

        MarketData md = getMarketData(marketId);

        if (md.oracle() != msg.sender) {
            revert OnlyOracle();
        }

        if (questionIndex >= md.questionCount()) {
            revert IndexOutOfBounds();
        }

        if (_outcome == true) {
            if (md.determined()) revert MarketAlreadyDetermined();
            md = md.determine(questionIndex);
        }

        bytes32 questionId = computeQuestionId(marketId, questionIndex);
        ctf.reportPayouts(questionId, Helpers._payouts(_outcome));
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _splitPosition(bytes32 _conditionId, uint256 _amount) internal {
        ctf.splitPosition(
            IERC20(address(wcol)),
            bytes32(0),
            _conditionId,
            Helpers._partition(),
            _amount
        );
    }

    function getConditionId(bytes32 _questionId) public view returns (bytes32) {
        return
            CTHelpers.getConditionId(
                address(this), // oracle
                _questionId,
                2 // outcomeCount
            );
    }
}
