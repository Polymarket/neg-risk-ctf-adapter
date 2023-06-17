// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IConditionalTokens} from "./interfaces/IConditionalTokens.sol";
import {ERC1155TokenReceiver} from "../lib/solmate/src/tokens/ERC1155.sol";
import {IERC1155TokenReceiver} from "./interfaces/IERC1155TokenReceiver.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {WrappedCollateral} from "./WrappedCollateral.sol";
import {Helpers} from "./libraries/Helpers.sol";
import {Admin} from "./modules/Admin.sol";
import {CTHelpers} from "./libraries/CTHelpers.sol";

interface INegRiskAdapterEE {
    error IndexOutOfBounds();
    error OnlyOracle();
    error IndexSetTooSmall();
    error MarketAlreadyPrepared();
    error MarketNotPrepared();
    error LengthMismatch();
    error ResultsAlreadySet();

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
contract NegRiskAdapter is INegRiskAdapterEE, ERC1155TokenReceiver {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    IConditionalTokens public immutable ctf;
    IERC20 public immutable col;
    WrappedCollateral public immutable wcol;
    address public constant noTokenBurnAddress =
        address(bytes20(bytes32(keccak256("NO_TOKEN_BURN_ADDRESS"))));
    address public constant vault =
        address(bytes20(bytes32(keccak256("VAULT"))));
    uint256 public constant feeDenominator = 1_00_00;

    // marketId => oracle
    mapping(bytes32 => address) public oracles;
    // marketId => questionCount
    mapping(bytes32 => uint256) public questionCounts;
    // marketId => feeBips
    mapping(bytes32 => uint256) public feeBips;
    // marketId => indexSet
    mapping(bytes32 => uint256) public results;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _ctf  - ConditionalTokens address
    /// @param _collateral - collateral address
    constructor(address _ctf, address _collateral) {
        ctf = IConditionalTokens(_ctf);
        col = IERC20(_collateral);
        wcol = new WrappedCollateral(address(col), col.decimals());
    }

    /*//////////////////////////////////////////////////////////////
                                  IDS
    //////////////////////////////////////////////////////////////*/

    function computeMarketId(
        address _oracle,
        bytes memory _data
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(_oracle, _data));
    }

    function computeQuestionId(
        bytes32 _marketId,
        uint256 _outcomeIndex
    ) public pure returns (bytes32) {
        unchecked {
            return bytes32(uint256(_marketId) + _outcomeIndex);
        }
    }

    function computePositionId(
        bytes32 _questionId,
        bool _outcome
    ) internal view returns (uint256) {
        bytes32 conditionId = CTHelpers.getConditionId(
            address(this), // oracle
            _questionId,
            2 // outcome count is always 2
        );

        bytes32 collectionId = CTHelpers.getCollectionId(
            bytes32(0),
            conditionId,
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
            Helpers._values(_amount),
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
            Helpers._values(_amount),
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
                             REPORT OUTCOME
    //////////////////////////////////////////////////////////////*/

    function reportOutcome(
        bytes32 _marketId,
        uint256 _index,
        bool _outcome
    ) external {
        if (oracles[_marketId] != msg.sender) {
            revert OnlyOracle();
        }

        if (_index >= questionCounts[_marketId]) {
            revert IndexOutOfBounds();
        }

        _reportOutcome(_marketId, _index, _outcome);
    }

    function reportOutcomes(
        bytes32 _marketId,
        uint256[] memory _indices,
        bool[] memory _outcomes
    ) external {
        if (oracles[_marketId] != msg.sender) {
            revert OnlyOracle();
        }

        uint256 i;
        uint256 length = _indices.length;

        if (length != _outcomes.length) {
            revert LengthMismatch();
        }

        uint256 questionCount = questionCounts[_marketId];

        while (i < length) {
            uint256 index = _indices[i];
            if (index < questionCount) {
                revert IndexOutOfBounds();
            }
            _reportOutcome(_marketId, index, _outcomes[index]);
        }
    }

    /*//////////////////////////////////////////////////////////////
                            CONVERT POSITION
    //////////////////////////////////////////////////////////////*/

    /// @notice _indexSet looks like 0x0000....01101
    /// @notice the lsb is the _first_ question
    function convertPosition(
        bytes32 _marketId,
        uint256 _amount,
        uint256 _indexSet
    ) external {
        uint256 questionCount = questionCounts[_marketId];

        if (_indexSet >> questionCount > 0) {
            revert IndexOutOfBounds();
        }

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
                if (_indexSet & (1 << index) == 1) {
                    // NO
                    positionIds[noIndex] = computePositionId(questionId, false);
                    ++noIndex;
                } else {
                    // YES
                    ctf.splitPosition(
                        IERC20(address(wcol)),
                        bytes32(0),
                        CTHelpers.getConditionId(
                            address(this), // oracle
                            questionId,
                            2 // outcomeCount
                        ),
                        Helpers._partition(),
                        _amount
                    );
                    positionIds[yesIndex] = computePositionId(questionId, true);
                    --yesIndex;
                }
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
            ctf.safeBatchTransferFrom(
                msg.sender,
                noTokenBurnAddress,
                noPositionIds,
                Helpers._values(_amount),
                ""
            );
        }

        uint256 amountOut = (_amount * feeBips[_marketId]) / 1_00_00;
        uint256 feeAmount = _amount - amountOut;

        // transfer yes tokens to sender
        if (yesPositionIds.length > 0) {
            ctf.safeBatchTransferFrom(
                address(this),
                msg.sender,
                yesPositionIds,
                Helpers._values(amountOut),
                ""
            );

            ctf.safeBatchTransferFrom(
                address(this),
                vault,
                yesPositionIds,
                Helpers._values(_amount - amountOut),
                ""
            );

            uint256 multiplier = (noPositionIds.length - 1);

            wcol.release(msg.sender, multiplier * amountOut);
            wcol.release(vault, multiplier * feeAmount);
        }
    }

    /*//////////////////////////////////////////////////////////////
                             PREPARE MARKET
    //////////////////////////////////////////////////////////////*/

    function prepareMarket(bytes memory _data) external returns (bytes32) {
        address oracle = msg.sender;
        bytes32 marketId = computeMarketId(oracle, _data);

        if (oracles[marketId] != address(0)) {
            revert MarketAlreadyPrepared();
        }

        oracles[marketId] = oracle;
        emit MarketPrepared(marketId, oracle, _data);

        return marketId;
    }

    /*//////////////////////////////////////////////////////////////
                            PREPARE QUESTION
    //////////////////////////////////////////////////////////////*/

    function prepareQuestion(
        bytes32 _marketId,
        bytes memory _data
    ) external returns (uint256) {
        address oracle = oracles[_marketId];

        if (oracle == address(0)) {
            revert MarketNotPrepared();
        }

        if (oracle != msg.sender) {
            revert OnlyOracle();
        }

        uint256 index = questionCounts[_marketId];
        bytes32 questionId = computeQuestionId(_marketId, index);

        ++questionCounts[_marketId];

        ctf.prepareCondition(address(this), questionId, 2);

        emit QuestionPrepared(questionId, _marketId, index, oracle, _data);

        return index;
    }

    /*//////////////////////////////////////////////////////////////
                                 ADMIN
    //////////////////////////////////////////////////////////////*/

    // to-do: onlyAdmin
    function withdrawFees(uint256 _amount) external {
        col.transfer(msg.sender, _amount);
    }

    /*//////////////////////////////////////////////////////////////
                                INTERNAL
    //////////////////////////////////////////////////////////////*/

    function _reportOutcome(
        bytes32 _marketId,
        uint256 _index,
        bool _outcome
    ) internal {
        if (_outcome == true) {
            if (results[_marketId] != 0) revert ResultsAlreadySet();
            results[_marketId] = 1 << _index;
        }

        bytes32 questionId = computeQuestionId(_marketId, _index);
        ctf.reportPayouts(questionId, Helpers._payouts(_outcome));
    }
}
