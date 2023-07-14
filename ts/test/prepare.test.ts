import { type Hex, zeroAddress } from "viem";
import { beforeAll, afterAll, expect, test, expectTypeOf } from "vitest";

import { deployAll } from "./setup/utils/deployAll";
import { ALICE } from "./setup/constants";
import { publicClient } from "./setup/clients";

let contracts: Awaited<ReturnType<typeof deployAll>>;
let marketId: Hex;

beforeAll(async () => {
  contracts = await deployAll();
});

test("can prepare market", async () => {
  const result = await contracts.negRiskAdapter.simulate.prepareMarket([BigInt(0), "0x"], { account: ALICE });
  expect(result).toBeDefined();

  marketId = result.result;
  expectTypeOf(marketId).toMatchTypeOf<Hex>;

  const prepareMarketHash = await contracts.negRiskAdapter.write.prepareMarket([BigInt(0), "0x"], {
    account: ALICE,
  });

  await publicClient.waitForTransactionReceipt({
    hash: prepareMarketHash,
  });

  const oracleAddress = await contracts.negRiskAdapter.read.getOracle([marketId]);

  expect(oracleAddress).to.not.equal(zeroAddress);
});

test("can prepare market and question", async () => {
  const questionCountBefore = await contracts.negRiskAdapter.read.getQuestionCount([marketId]);
  expect(questionCountBefore).toEqual(BigInt(0));

  const prepareQuestionHash = await contracts.negRiskAdapter.write.prepareQuestion([marketId, "0x"], {
    account: ALICE,
  });

  await publicClient.waitForTransactionReceipt({
    hash: prepareQuestionHash,
  });

  const questionCountAfter = await contracts.negRiskAdapter.read.getQuestionCount([marketId]);
  expect(questionCountAfter).toEqual(BigInt(1));
});

afterAll(async () => {
  return;
});
