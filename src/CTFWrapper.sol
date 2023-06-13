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
    address private erc1155Recipient;
    bytes32 constant parentCollectionId = bytes32(0);

    // marketId => questionIds
    mapping(bytes32 => bytes32[]) public questionIds;
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
            parentCollectionId,
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
        uint256[] memory partition = Helpers._partition();

        // 1. need to compute positionIds
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
            parentCollectionId,
            _conditionId,
            partition,
            _amount
        );

        pusdc.transfer(msg.sender, _amount);
    }

    function prepareConditionUnderMarket(
        address _oracle,
        bytes32 _marketId
    ) external {
        uint256 conditionIndex = questionIds[_marketId].length;
        bytes32 questionId = keccak256(abi.encode(_marketId, conditionIndex));
        ctf.prepareCondition(_oracle, questionId, 2);
        questionIds[_marketId].push(questionId);
    }

    function negativeRisk(
        bytes32 _marketId,
        uint256 _amount,
        bytes32[] memory _questionIds
    ) external {
        uint256 i;
        uint256 noTokensLength = _questionIds.length;

        while (i < noTokensLength) {
            if (marketIds[_questionIds[i]] != _marketId) {
                revert("questionId not associated with marketId");
            }
        }

        uint256[] memory noPositionIds = _noPositionIds(_questionIds);

        // transfer no tokens to this contract
        ctf.safeBatchTransferFrom(
            msg.sender,
            address(this),
            noPositionIds,
            Helpers._values(_amount),
            ""
        );

        uint256 marketTokensLength = questionIds[_marketId].length;

        i = 0;

        uint256 yesTokensLength = marketTokensLength - noTokensLength;

        bytes32[] memory yesQuestionIds = new bytes32[](yesTokensLength);

        uint256 j = 0;
        uint256 yesIndex;

        // loop through all questionIds
        while (i < marketTokensLength) {
            // loop through all no questionIds
            bool found;
            while (j < noTokensLength) {
                // if the questionId is not a no questionId, then it is a yes questionId
                if (questionIds[_marketId][i] == _questionIds[j]) {
                    found = true;
                    break;
                }
                ++j;
            }
            if (found == true) {
                yesQuestionIds[yesIndex] = questionIds[_marketId][i];
                yesIndex++;
            }
            ++i;
        }

        // split all positions with fake pusdc
        // to-do: add mint of pusdc
        pusdc.mint(_amount);

        i = 0;
        while (i < yesTokensLength) {
            ctf.splitPosition(
                IERC20(address(pusdc)),
                bytes32(0),
                CTHelpers.getConditionId(
                    address(0), // oracle
                    yesQuestionIds[i],
                    2
                ),
                Helpers._partition(),
                _amount
            );
        }

        uint256[] memory yesPositionIds = _yesPositionIds(yesQuestionIds);

        ctf.safeBatchTransferFrom(
            address(this),
            msg.sender,
            yesPositionIds,
            Helpers._values(_amount),
            ""
        );
    }

    function _yesPositionIds(
        bytes32[] memory _questionIds
    ) internal view returns (uint256[] memory) {
        uint256[] memory positionIds = new uint256[](_questionIds.length);
        uint256 i;
        uint256 length = _questionIds.length;

        while (i < length) {
            bytes32 conditionId = CTHelpers.getConditionId(
                address(0), // oracle
                _questionIds[i],
                2
            );
            bytes32 collectionId = CTHelpers.getCollectionId(
                parentCollectionId,
                conditionId,
                1
            );
            positionIds[i] = CTHelpers.getPositionId(
                address(pusdc),
                collectionId
            );
        }

        return positionIds;
    }

    function _noPositionIds(
        bytes32[] memory _questionIds
    ) internal view returns (uint256[] memory) {
        uint256[] memory positionIds = new uint256[](_questionIds.length);
        uint256 i;
        uint256 length = _questionIds.length;

        while (i < length) {
            bytes32 conditionId = CTHelpers.getConditionId(
                address(0), // oracle
                _questionIds[i],
                2
            );
            bytes32 collectionId = CTHelpers.getCollectionId(
                parentCollectionId,
                conditionId,
                2
            );
            positionIds[i] = CTHelpers.getPositionId(
                address(pusdc),
                collectionId
            );
        }

        return positionIds;
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
