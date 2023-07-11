import { ALICE, BOB } from "./setup/constants";
import { publicClient, walletClient } from "./setup/utils";
import { umaCtfAdapterContract } from "../contracts/umaCtfAdapter";
import { finderContract } from "../contracts/finder";
import { type Address, type TransactionReceipt, isAddress, zeroAddress } from "viem";
import { beforeAll, afterAll, expect, test } from "vitest";

let umaCtfAdapterAddress: Address;
let ctfAddress: Address;
let finderAddress: Address;
let receipt: TransactionReceipt;

beforeAll(async () => {
  const finderHash = await walletClient.deployContract({
    ...finderContract,
    args: [zeroAddress, zeroAddress],
    account: ALICE,
  });

  const finderReceipt = await publicClient.waitForTransactionReceipt({
    hash: finderHash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const finderAddress = finderReceipt.contractAddress!;

  const hash = await walletClient.deployContract({
    ...umaCtfAdapterContract,
    args: [zeroAddress, finderAddress],
    // args: [ctfAddress, finderAddress],
    // This account is already unlocked by anvil. If you were to use an account that is not unlocked, you'd
    // have to impersonate it first using `testClient.impersonateAccount(<account>)`.
    account: ALICE,
  });

  receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  umaCtfAdapterAddress = receipt.contractAddress!;
});

test("can deploy the umaCtfAdapter contract", async () => {
  expect(umaCtfAdapterAddress).toBeDefined();
  expect(isAddress(umaCtfAdapterAddress)).toBe(true);
});

afterAll(async () => {
  return;
});
