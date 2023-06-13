// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IConditionalTokens} from "./interfaces/IConditionalTokens.sol";
import {ERC1155TokenReceiver} from "../lib/solmate/src/tokens/ERC1155.sol";
import {IERC1155TokenReceiver} from "./interfaces/IERC1155TokenReceiver.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {PUSDC} from "./PUSDC.sol";
import {CTHelpers} from "./libraries/CTHelpers.sol";
import {Helpers} from "./libraries/Helpers.sol";

/// @title CTFWrapper
/// @author Mike Shrieve (mike@polymarket.com)
contract CTFWrapper is IERC1155TokenReceiver {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    IConditionalTokens public immutable ctf;
    IERC20 public immutable usdc;
    PUSDC public immutable pusdc;

    mapping(bytes32 => uint256) public outcomeCounts;
    // questionId => marketId
    mapping(bytes32 => bytes32) public marketIds;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @param _ctf  - ConditionalTokens address
    /// @param _usdc - USDC address
    constructor(address _ctf, address _usdc) {
        ctf = IConditionalTokens(_ctf);
        usdc = IERC20(_usdc);
        pusdc = new PUSDC(address(this), _usdc);
    }

    /*//////////////////////////////////////////////////////////////
                             SPLIT POSITION
    //////////////////////////////////////////////////////////////*/

    function splitPosition(bytes32 _conditionId, uint256 _amount) external {
        usdc.transferFrom(msg.sender, address(this), _amount);

        pusdc.wrap(_amount);

        ctf.splitPosition(
            IERC20(address(pusdc)),
            bytes32(0),
            _conditionId,
            Helpers._partition(),
            _amount
        );

        ctf.safeBatchTransferFrom(
            address(this),
            msg.sender,
            Helpers._positionIds(address(pusdc), _conditionId),
            Helpers._values(_amount),
            ""
        );
    }

    function mergePositions(bytes32 _conditionId, uint _amount) external {
        uint256[] memory positionIds = Helpers._positionIds(
            address(pusdc),
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
            IERC20(address(pusdc)),
            bytes32(0),
            _conditionId,
            Helpers._partition(),
            _amount
        );

        pusdc.transfer(msg.sender, _amount);
    }

    function addOutcome(address _oracle, bytes32 _marketId) external {
        uint256 outcomeIndex = outcomeCounts[_marketId];
        bytes32 questionId = _computeQuestionId(_marketId, outcomeIndex);
        ctf.prepareCondition(_oracle, questionId, 2);
        ++outcomeCounts[_marketId];
    }

    // what if instead of questionIds we use an indexSet
    // which looks like 0x0000....01101
    // the lsb is the _first_ outcome
    // this is the same as index sets
    function negativeRisk(
        bytes32 _marketId,
        uint256 _amount,
        uint256 _indexSet
    ) external {
        uint256 noTokensLength;

        // count index set size
        {
            uint256 indexSet = _indexSet;
            while (indexSet > 0) {
                if (indexSet & 1 == 1) {
                    ++noTokensLength;
                }
                indexSet >>= 1;
            }
        }

        uint256 outcomeCount = outcomeCounts[_marketId];
        uint256 yesTokensLength = outcomeCount - noTokensLength;

        uint256[] memory yesPositionIds = new uint256[](yesTokensLength);
        uint256[] memory noPositionIds = new uint256[](noTokensLength);

        // split yes conditions
        // and compute positionIds
        {
            pusdc.mint(yesTokensLength * _amount);

            uint256 outcomeIndex;
            uint256 noIndex;
            uint256 yesIndex;

            while (outcomeIndex < outcomeCount) {
                bytes32 questionId = _computeQuestionId(
                    _marketId,
                    outcomeIndex
                );

                if (_indexSet & (1 << outcomeIndex) == 1) {
                    noPositionIds[noIndex] = _computePositionId(
                        questionId,
                        false
                    );

                    ++noIndex;
                } else {
                    ctf.splitPosition(
                        IERC20(address(pusdc)),
                        bytes32(0),
                        CTHelpers.getConditionId(
                            address(0), // oracle
                            questionId,
                            2 // outcomeCount
                        ),
                        Helpers._partition(),
                        _amount
                    );

                    yesPositionIds[yesIndex] = _computePositionId(
                        questionId,
                        true
                    );

                    ++yesIndex;
                }
                ++outcomeIndex;
            }
        }

        // transfer no tokens to this contract
        {
            ctf.safeBatchTransferFrom(
                msg.sender,
                address(this),
                noPositionIds,
                Helpers._values(_amount),
                ""
            );
        }

        // transfer yes tokens to sender
        {
            ctf.safeBatchTransferFrom(
                address(this),
                msg.sender,
                yesPositionIds,
                Helpers._values(_amount),
                ""
            );
        }
    }

    function _computePositionId(
        bytes32 _questionId,
        bool _outcome
    ) internal view returns (uint256) {
        bytes32 conditionId = CTHelpers.getConditionId(
            address(0), // oracle
            _questionId,
            2 // outcome count is always 2
        );

        bytes32 collectionId = CTHelpers.getCollectionId(
            bytes32(0),
            conditionId,
            _outcome ? 1 : 2 // 1 is yes, 2 is no
        );

        uint256 positionId = CTHelpers.getPositionId(
            address(pusdc),
            collectionId
        );

        return positionId;
    }

    function _computeQuestionId(
        bytes32 _marketId,
        uint256 _outcomeIndex
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_marketId, _outcomeIndex));
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4) {
        return ERC1155TokenReceiver.onERC1155BatchReceived.selector;
    }
}
