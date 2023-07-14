import { type Address, isAddress } from "viem";
import { beforeAll, afterAll, expect, test } from "vitest";

import { deployContract } from "ts/test/setup/utils/deployContract";

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
} from "../contracts/abi";

let umaCtfAdapterAddress: Address;
let conditionalTokensAddress: Address;
let finderAddress: Address;
let optimisticOracleAddress: Address;
let collateralWhitelistAddress: Address;
let vaultAddress: Address;
let usdcAddress: Address;
let negRiskAdapterAddress: Address;
let negRiskOperatorAddress: Address;

beforeAll(async () => {
  conditionalTokensAddress = await deployContract({
    ...conditionalTokens,
    args: [],
  });

  optimisticOracleAddress = await deployContract({
    ...mockOptimisticOracleV2,
    args: [],
  });

  collateralWhitelistAddress = await deployContract({
    ...mockCollateralWhitelist,
    args: [],
  });

  finderAddress = await deployContract({
    ...finder,
    args: [optimisticOracleAddress, collateralWhitelistAddress],
  });

  vaultAddress = await deployContract({
    ...vault,
    args: [],
  });

  umaCtfAdapterAddress = await deployContract({
    ...umaCtfAdapter,
    args: [conditionalTokensAddress, finderAddress],
  });

  usdcAddress = await deployContract({
    ...mockUSDC,
    args: [],
  });

  negRiskAdapterAddress = await deployContract({
    ...negRiskAdapter,
    args: [conditionalTokensAddress, usdcAddress, vaultAddress],
  });

  negRiskOperatorAddress = await deployContract({
    ...negRiskOperator,
    args: [negRiskAdapterAddress],
  });
});

test("can deploy contracts", async () => {
  expect(isAddress(optimisticOracleAddress)).toBe(true);
  expect(isAddress(collateralWhitelistAddress)).toBe(true);
  expect(isAddress(finderAddress)).toBe(true);
  expect(isAddress(vaultAddress)).toBe(true);
  expect(isAddress(umaCtfAdapterAddress)).toBe(true);
  expect(isAddress(usdcAddress)).toBe(true);
  expect(isAddress(negRiskAdapterAddress)).toBe(true);
  expect(isAddress(negRiskOperatorAddress)).toBe(true);
});

afterAll(async () => {
  return;
});
