import { type Hex, zeroAddress } from "viem";
import { beforeAll, afterAll, expect, test, expectTypeOf } from "vitest";

import { deployAll } from "./setup/utils/deployAll";
import { ADMIN, ALICE } from "./setup/constants";
import { publicClient, walletClient } from "./setup/clients";
import { getNegRiskOperator } from "../contracts/negRiskOperator";

let contracts: Awaited<ReturnType<typeof deployAll>>;
// let marketId: Hex;

beforeAll(async () => {
  contracts = await deployAll();
});

test("can get negRiskOperator", async () => {
  const negRiskOperator = getNegRiskOperator({
    address: contracts.negRiskOperator.address,
    publicClient,
    walletClient,
  });

  expect(negRiskOperator.read).toBeDefined();
  expect(negRiskOperator.write).toBeDefined();

  const isAdminAdmin = await negRiskOperator.read.isAdmin([ADMIN]);
  expect(isAdminAdmin).toEqual(true);

  const isAliceAdmin = await negRiskOperator.read.isAdmin([ALICE]);
  expect(isAliceAdmin).toEqual(false);
});

test("can get negRiskOperator read only", async () => {
  const negRiskOperator = getNegRiskOperator({
    address: contracts.negRiskOperator.address,
    publicClient,
  });

  expect(negRiskOperator.read).toBeDefined();
  expect(negRiskOperator.write).toBeUndefined();
});

afterAll(async () => {
  return;
});
