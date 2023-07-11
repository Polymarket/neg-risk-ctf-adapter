import { ALICE } from "../test/setup/constants";
import { publicClient, walletClient } from "../test/setup/utils";
import { finderContract } from "../contracts/finder";

import { type Address, type TransactionReceipt, isAddress, zeroAddress } from "viem";

// let umaCtfAdapterAddress: Address;
// let ctfAddress: Address;
// let finderAddress: Address;
// let receipt: TransactionReceipt;

const deployFinder = async (optimisticOracleV2Address: Address, collateralWhitelistAddress: Address) => {
  const hash = await walletClient.deployContract({
    ...finderContract,
    args: [optimisticOracleV2Address, collateralWhitelistAddress],
    account: ALICE,
  });

  const receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const address = receipt.contractAddress!;

  return address;
};

export { deployFinder };
