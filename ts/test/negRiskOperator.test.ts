import { stringToHex, getContract } from "viem";
import { afterAll, expect, test, beforeEach } from "vitest";

import { deployAll } from "./setup/utils/deployAll";
import { ADMIN, ALICE, BRIAN } from "./setup/constants";
import { publicClient, walletClient } from "./setup/clients";
import { getNegRiskOperator } from "../contracts/negRiskOperator";
import { negRiskAdapter } from "../contracts/abi";
import { getMarketId } from "../utils/getMarketId";

let contracts: Awaited<ReturnType<typeof deployAll>>;

beforeEach(async () => {
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

test("can add admin", async () => {
  const negRiskOperator = getNegRiskOperator({
    address: contracts.negRiskOperator.address,
    publicClient,
    walletClient,
  });

  const addAdminTxHash = await negRiskOperator.write.addAdmin([BRIAN], {
    account: ADMIN,
  });

  await publicClient.waitForTransactionReceipt({ hash: addAdminTxHash });

  const isBrianAdmin = await negRiskOperator.read.isAdmin([BRIAN]);

  expect(isBrianAdmin).toEqual(true);

  const renounceAdminTxHash = await negRiskOperator.write.renounceAdmin({
    account: ADMIN,
  });

  await publicClient.waitForTransactionReceipt({ hash: renounceAdminTxHash });

  const isAdminAdmin = await negRiskOperator.read.isAdmin([ADMIN]);

  expect(isBrianAdmin).toEqual(true);
  expect(isAdminAdmin).toEqual(false);
});

test("getMarketId is correct", async () => {
  const negRiskOperatorContract = getNegRiskOperator({
    address: contracts.negRiskOperator.address,
    publicClient,
    walletClient,
  });

  const metadata = stringToHex("multi-outcome market !!");
  const feeBips = 0n;

  const prepareMarketResult =
    await negRiskOperatorContract.simulate.prepareMarket([0n, metadata], {
      account: ADMIN,
    });

  const actualMarketId = prepareMarketResult.result;

  const computedMarketId = getMarketId(
    contracts.negRiskOperator.address,
    feeBips,
    metadata
  );

  expect(computedMarketId).toEqual(actualMarketId);
});

test("can prepare market", async () => {
  const negRiskOperatorContract = getNegRiskOperator({
    address: contracts.negRiskOperator.address,
    publicClient,
    walletClient,
  });

  const negRiskAdapterContract = getContract({
    abi: negRiskAdapter.abi,
    address: contracts.negRiskAdapter.address,
    publicClient,
    walletClient,
  });

  const prepareMarketResult =
    await negRiskOperatorContract.simulate.prepareMarket(
      [0n, stringToHex("multi-outcome market")],
      {
        account: ADMIN,
      }
    );

  const marketId = prepareMarketResult.result;

  const prepareMarketTxHash = await negRiskOperatorContract.write.prepareMarket(
    [0n, stringToHex("multi-outcome market")],
    {
      account: ADMIN,
    }
  );

  await publicClient.waitForTransactionReceipt({ hash: prepareMarketTxHash });

  const marketOracle = await negRiskAdapterContract.read.getOracle([marketId]);

  expect(marketOracle).toEqual(contracts.negRiskOperator.address);
});

afterAll(async () => {
  return;
});
