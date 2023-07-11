import { ALICE } from "../test/setup/constants";
import { publicClient, walletClient } from "../test/setup/utils";
import { negReskOperatorContract } from "../contracts/negRiskOperator";

import { type Address, type TransactionReceipt, isAddress, zeroAddress } from "viem";

// let umaCtfAdapterAddress: Address;
// let ctfAddress: Address;
// let finderAddress: Address;
// let receipt: TransactionReceipt;

const deployNegRiskOperator = async (negRiskAdapterAddress: Address) => {
  const hash = await walletClient.deployContract({
    ...negReskOperatorContract,
    args: [negRiskAdapterAddress],
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
