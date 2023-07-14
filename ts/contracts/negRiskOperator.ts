import { Address, getContract, PublicClient, WalletClient } from "viem";
import { negRiskOperator } from "./abi/negRiskOperator.js";
import type { Contract } from "../types";

type GetGenericContractArgs<TPublicClient extends PublicClient, TWalletClient extends WalletClient> = {
  address: Address;
  publicClient: TPublicClient;
  walletClient?: TWalletClient;
};

const getNegRiskOperator = <TPublicClient extends PublicClient, TWalletClient extends WalletClient>(
  args: GetGenericContractArgs<TPublicClient, TWalletClient>,
): Contract<typeof negRiskOperator.abi, TPublicClient, TWalletClient> =>
  getContract({
    ...args,
    abi: negRiskOperator.abi,
  });

// const getNegRiskOperator = <TPublicClient extends PublicClient, TWalletClient extends WalletClient>(
//   args: GetGenericContractArgs<TPublicClient, TWalletClient>,
// ): Contract<typeof negRiskOperator.abi, TPublicClient, TWalletClient> =>
//   getContract({
//     ...args,
//     abi: negRiskOperator.abi,
//   });

//
export { getNegRiskOperator };
