import { deployAndGetContract } from "ts/test/setup/utils/deployAndGetContract";

import {
  conditionalTokens,
  mockCollateralWhitelist,
  mockOptimisticOracleV2,
  mockUSDC,
  vault,
  finder,
  umaCtfAdapter,
  negRiskAdapter,
  negRiskOperator,
} from "../../../contracts/abi";

const deployAll = async () => {
  const conditionalTokensContract = await deployAndGetContract({
    ...conditionalTokens,
    args: [],
  });

  const optimisticOracleContract = await deployAndGetContract({
    ...mockOptimisticOracleV2,
    args: [],
  });

  const collateralWhitelistContract = await deployAndGetContract({
    ...mockCollateralWhitelist,
    args: [],
  });

  const finderContract = await deployAndGetContract({
    ...finder,
    args: [optimisticOracleContract.address, collateralWhitelistContract.address],
  });

  const vaultContract = await deployAndGetContract({
    ...vault,
    args: [],
  });

  const umaCtfAdapterContract = await deployAndGetContract({
    ...umaCtfAdapter,
    args: [conditionalTokensContract.address, finderContract.address],
  });

  const usdcContract = await deployAndGetContract({
    ...mockUSDC,
    args: [],
  });

  const negRiskAdapterContract = await deployAndGetContract({
    ...negRiskAdapter,
    args: [conditionalTokensContract.address, usdcContract.address, vaultContract.address],
  });

  const negRiskOperatorContract = await deployAndGetContract({
    ...negRiskOperator,
    args: [negRiskAdapterContract.address],
  });

  return {
    conditionalTokens: conditionalTokensContract,
    optimisticOracle: optimisticOracleContract,
    collateralWhitelist: collateralWhitelistContract,
    finder: finderContract,
    vault: vaultContract,
    umaCtfAdapter: umaCtfAdapterContract,
    usdc: usdcContract,
    negRiskAdapter: negRiskAdapterContract,
    negRiskOperator: negRiskOperatorContract,
  };
};

export { deployAll };
