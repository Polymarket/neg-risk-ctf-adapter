import { type Address, isAddress, type Hex } from "viem";
import { beforeAll, afterAll, expect, test, expectTypeOf } from "vitest";

import { deployAll } from "./setup/utils/deployAll";
import { ALICE } from "./setup/constants";
import { publicClient } from "./setup/clients";

let contracts: Awaited<ReturnType<typeof deployAll>>;

beforeAll(async () => {
  contracts = await deployAll();
});

test("can prepare market", async () => {
  const result = await contracts.negRiskAdapter.simulate.prepareMarket([BigInt(0), "0x"]);
  expect(result).toBeDefined();
  expectTypeOf(result.result).toMatchTypeOf<Hex>;

  const prepareMarketHash = await contracts.negRiskAdapter.write.prepareMarket([BigInt(0), "0x"], {
    account: ALICE,
  });

  await publicClient.waitForTransactionReceipt({
    hash: prepareMarketHash,
  });
});

afterAll(async () => {
  return;
});
