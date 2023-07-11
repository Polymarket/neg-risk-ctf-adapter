import { ALICE } from "../test/setup/constants";
import { publicClient, walletClient } from "../test/setup/utils";
import { negRiskAdapterContract } from "../contracts/negRiskAdapter";

import { type Address, type TransactionReceipt, isAddress, zeroAddress } from "viem";

// let umaCtfAdapterAddress: Address;
// let ctfAddress: Address;
// let finderAddress: Address;
// let receipt: TransactionReceipt;

const deployNegRiskAdapter = async (ctfAddress: Address, collateralAddress: Address, vaultAddress: Address) => {
  const hash = await walletClient.deployContract({
    ...negRiskAdapterContract,
    args: [ctfAddress, collateralAddress, vaultAddress],
    account: ALICE,
  });

  const receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const address = receipt.contractAddress!;

  return address;
};

export { deployNegRiskAdapter };
