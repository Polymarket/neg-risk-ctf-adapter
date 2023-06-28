// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {TestHelper, console} from "src/dev/TestHelper.sol";

import {NegRiskAdapter, INegRiskAdapterEE} from "src/NegRiskAdapter.sol";
import {NegRiskOperator} from "src/NegRiskOperator.sol";
import {WrappedCollateral} from "src/WrappedCollateral.sol";
import {DeployLib} from "src/dev/libraries/DeployLib.sol";
import {USDC} from "src/test/mock/USDC.sol";
import {IConditionalTokens} from "src/interfaces/IConditionalTokens.sol";
import {IUmaCtfAdapter} from "src/interfaces/IUmaCtfAdapter.sol";
import {Finder} from "src/test/mock/Finder.sol";
import {CollateralWhitelist} from "src/test/mock/CollateralWhitelist.sol";
import {OptimisticOracleV2} from "src/test/mock/OptimisticOracleV2.sol";

contract IntegrationTest is TestHelper {
    NegRiskAdapter nrAdapter;
    NegRiskOperator nrOperator;
    IUmaCtfAdapter umaCtfAdapter;
    OptimisticOracleV2 optimisticOracle;

    USDC usdc;
    WrappedCollateral wcol;
    IConditionalTokens ctf;
    address vault;
    address admin;

    function setUp() public virtual {
        vault = _getAndLabelAddress("vault");
        admin = _getAndLabelAddress("admin");

        ctf = IConditionalTokens(DeployLib.deployConditionalTokens());
        usdc = new USDC();

        nrAdapter = new NegRiskAdapter(address(ctf), address(usdc), vault);
        wcol = nrAdapter.wcol();

        CollateralWhitelist collateralWhitelist = new CollateralWhitelist();
        optimisticOracle = new OptimisticOracleV2();

        Finder finder = new Finder(address(optimisticOracle), address(collateralWhitelist));

        vm.prank(admin);
        nrOperator = new NegRiskOperator(address(nrAdapter));

        umaCtfAdapter =
            IUmaCtfAdapter(DeployLib.deployUmaCtfAdapter(address(nrOperator), address(finder)));

        vm.prank(admin);
        nrOperator.setOracle(address(umaCtfAdapter));
    }

    function test_initialize() public {
        bytes memory ancillaryData = new bytes(100);
        address rewardToken = address(usdc);
        uint256 reward = 1_000_000;
        uint256 proposalBond = 5_000_000;
        uint256 liveness = 100;

        vm.startPrank(brian);
        usdc.mint(brian, reward);
        usdc.approve(address(umaCtfAdapter), reward);
        bytes32 requestId =
            umaCtfAdapter.initialize(ancillaryData, rewardToken, reward, proposalBond, liveness);

        assertNotEq(requestId, bytes32(0));
    }

    function test_initializeAndPrepare() public {
        bytes memory data = new bytes(100);

        vm.prank(admin);
        bytes32 marketId = nrOperator.prepareMarket(data, 0);

        address rewardToken = address(usdc);
        uint256 reward = 1_000_000;
        uint256 proposalBond = 5_000_000;
        uint256 liveness = 100;

        vm.startPrank(brian);
        usdc.mint(brian, reward);
        usdc.approve(address(umaCtfAdapter), reward);
        bytes32 requestId =
            umaCtfAdapter.initialize(data, rewardToken, reward, proposalBond, liveness);

        vm.stopPrank();

        vm.prank(admin);
        nrOperator.prepareQuestion(marketId, data, requestId);
    }

    function test_initializePrepareAndResolve() public {
        bytes memory data = new bytes(100);

        vm.prank(admin);
        bytes32 marketId = nrOperator.prepareMarket(data, 0);

        address rewardToken = address(usdc);
        uint256 reward = 1_000_000;
        uint256 proposalBond = 5_000_000;
        uint256 liveness = 100;

        vm.startPrank(brian);
        usdc.mint(brian, reward);
        usdc.approve(address(umaCtfAdapter), reward);
        bytes32 requestId =
            umaCtfAdapter.initialize(data, rewardToken, reward, proposalBond, liveness);

        vm.stopPrank();

        // prepare dummy question
        vm.prank(admin);
        nrOperator.prepareQuestion(marketId, data, bytes32(0));

        // prepare the question to resolve, index 1
        vm.prank(admin);
        bytes32 questionId = nrOperator.prepareQuestion(marketId, data, requestId);

        // yes
        optimisticOracle.setPrice(1 ether);

        umaCtfAdapter.resolve(requestId);

        assertTrue(nrOperator.results(questionId));
        assertEq(nrOperator.reportedAt(questionId), block.timestamp);

        skip(nrOperator.delayPeriod());

        nrOperator.resolveQuestion(questionId);

        assertTrue(nrAdapter.getDetermined(marketId));
        assertEq(nrAdapter.getResult(marketId), 1);
    }
}
