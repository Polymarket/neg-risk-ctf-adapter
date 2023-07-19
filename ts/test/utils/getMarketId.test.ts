import { stringToHex, toHex } from "viem";
import { afterAll, expect, test, beforeEach } from "vitest";

import { deployAll } from "../setup/utils/deployAll";
import { randomBytes } from "crypto";
import { getMarketId } from "ts/utils/getMarketId";

let contracts: Awaited<ReturnType<typeof deployAll>>;

beforeEach(async () => {
  contracts = await deployAll();
});

test("getMarketId is correct", async () => {
  const oracle = toHex(randomBytes(20));
  const metadata = toHex(randomBytes(200));

  const feeBips = 1_00n;

  const prepareMarketResult = await contracts.negRiskAdapter.simulate.prepareMarket([feeBips, metadata], {
    account: oracle,
  });

  const actualMarketId = prepareMarketResult.result;

  const computedMarketId = getMarketId(oracle, feeBips, metadata);

  expect(computedMarketId).toEqual(actualMarketId);
});

afterAll(async () => {
  return;
});
