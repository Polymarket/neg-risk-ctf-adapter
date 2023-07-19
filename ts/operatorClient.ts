import { getNegRiskOperator } from "./contracts/negRiskOperator";
import { publicClient, walletClient } from "./contracts/clients";
import { Address } from "viem";

const getOperatorClient = async (address: Address) => {
  const negRiskOperator = await getNegRiskOperator({
    address,
    publicClient,
    walletClient,
  });

  return negRiskOperator;
};

export { getOperatorClient };
