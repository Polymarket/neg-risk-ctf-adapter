// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface INegRiskAdapter {
    type MarketData is bytes32;

    error DeterminedFlagAlreadySet();
    error FeeBipsOutOfBounds();
    error IndexOutOfBounds();
    error InvalidIndexSet();
    error LengthMismatch();
    error MarketAlreadyDetermined();
    error MarketAlreadyPrepared();
    error MarketNotPrepared();
    error NoConvertiblePositions();
    error NotAdmin();
    error NotApprovedForAll();
    error OnlyOracle();
    error UnexpectedCollateralToken();

    event MarketPrepared(bytes32 indexed marketId, address indexed oracle, uint256 feeBips, bytes data);
    event NewAdmin(address indexed admin, address indexed newAdminAddress);
    event OutcomeReported(bytes32 indexed marketId, bytes32 indexed questionId, bool outcome);
    event PayoutRedemption(address indexed redeemer, bytes32 indexed conditionId, uint256[] amounts, uint256 payout);
    event PositionSplit(address indexed stakeholder, bytes32 indexed conditionId, uint256 amount);
    event PositionsConverted(
        address indexed stakeholder, bytes32 indexed marketId, uint256 indexed indexSet, uint256 amount
    );
    event PositionsMerge(address indexed stakeholder, bytes32 indexed conditionId, uint256 amount);
    event QuestionPrepared(bytes32 indexed marketId, bytes32 indexed questionId, uint256 index, bytes data);
    event RemovedAdmin(address indexed admin, address indexed removedAdmin);

    function FEE_DENOMINATOR() external view returns (uint256);
    function NO_TOKEN_BURN_ADDRESS() external view returns (address);
    function addAdmin(address admin) external;
    function admins(address) external view returns (uint256);
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    function balanceOfBatch(address[] memory _owners, uint256[] memory _ids) external view returns (uint256[] memory);
    function col() external view returns (address);
    function convertPositions(bytes32 _marketId, uint256 _indexSet, uint256 _amount) external;
    function ctf() external view returns (address);
    function getConditionId(bytes32 _questionId) external view returns (bytes32);
    function getDetermined(bytes32 _marketId) external view returns (bool);
    function getFeeBips(bytes32 _marketId) external view returns (uint256);
    function getMarketData(bytes32 _marketId) external view returns (MarketData);
    function getOracle(bytes32 _marketId) external view returns (address);
    function getPositionId(bytes32 _questionId, bool _outcome) external view returns (uint256);
    function getQuestionCount(bytes32 _marketId) external view returns (uint256);
    function getResult(bytes32 _marketId) external view returns (uint256);
    function isAdmin(address addr) external view returns (bool);
    function mergePositions(address _collateralToken, bytes32, bytes32 _conditionId, uint256[] memory, uint256 _amount)
        external;
    function mergePositions(bytes32 _conditionId, uint256 _amount) external;
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
        external
        returns (bytes4);
    function onERC1155Received(address, address, uint256, uint256, bytes memory) external returns (bytes4);
    function prepareMarket(uint256 _feeBips, bytes memory _metadata) external returns (bytes32);
    function prepareQuestion(bytes32 _marketId, bytes memory _metadata) external returns (bytes32);
    function redeemPositions(bytes32 _conditionId, uint256[] memory _amounts) external;
    function removeAdmin(address admin) external;
    function renounceAdmin() external;
    function reportOutcome(bytes32 _questionId, bool _outcome) external;
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) external;
    function splitPosition(address _collateralToken, bytes32, bytes32 _conditionId, uint256[] memory, uint256 _amount)
        external;
    function splitPosition(bytes32 _conditionId, uint256 _amount) external;
    function vault() external view returns (address);
    function wcol() external view returns (address);
}
