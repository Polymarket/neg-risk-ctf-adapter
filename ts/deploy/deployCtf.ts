import { ALICE } from "../test/setup/constants";
import { publicClient, walletClient } from "../test/setup/utils";
import { ctfContract } from "../contracts/ctf";

import { type Address, type TransactionReceipt, isAddress, zeroAddress } from "viem";

// let umaCtfAdapterAddress: Address;
// let ctfAddress: Address;
// let finderAddress: Address;
// let receipt: TransactionReceipt;

const deployCtf = async () => {
  const hash = await walletClient.deployContract({
    ...ctfContract,
    account: ALICE,
  });

  const receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const address = receipt.contractAddress!;

  return address;
};

export { deployCtf };
