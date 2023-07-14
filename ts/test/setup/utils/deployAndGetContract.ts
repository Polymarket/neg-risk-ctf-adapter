import { ADMIN } from "../constants";
import { publicClient, walletClient } from "../clients";
import { type Hex, getContract, type GetContractReturnType } from "viem";
import { Abi, AbiParameter, AbiParametersToPrimitiveTypes, AbiConstructor, Address } from "abitype";

export type GetConstructorArgs<
  TAbi extends Abi | readonly unknown[],
  TAbiConstructor extends AbiConstructor = TAbi extends Abi
    ? Extract<TAbi[number], { type: "constructor" }>
    : AbiConstructor,
  TArgs = AbiParametersToPrimitiveTypes<TAbiConstructor["inputs"]>,
  FailedToParseArgs = ([TArgs] extends [never] ? true : false) | (readonly unknown[] extends TArgs ? true : false),
> = true extends FailedToParseArgs ? readonly [] : TArgs;

type DeployContractArgs<TAbi extends Abi, TArgs = GetConstructorArgs<TAbi>> = {
  abi: TAbi;
  args: TArgs;
  bytecode: Hex;
};

type Contract<TAbi extends Abi> = GetContractReturnType<TAbi, typeof publicClient, typeof walletClient> & {
  address: Address;
};

const deployAndGetContract = async <TAbi extends Abi>({
  abi,
  args,
  bytecode,
}: DeployContractArgs<TAbi>): Promise<Contract<TAbi>> => {
  const hash = await walletClient.deployContract({
    abi: abi as Abi,
    args: args as AbiParameter[],
    bytecode,
    account: ADMIN,
  });

  const receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const address = receipt.contractAddress!;

  const contract = getContract({
    address,
    abi,
    publicClient,
    walletClient,
  });

  return contract;
};

export { deployAndGetContract };
export type { Contract };
