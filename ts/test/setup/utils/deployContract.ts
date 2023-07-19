import { ALICE } from "../constants";
import { publicClient, walletClient } from "../clients";
import { Hex, getAddress } from "viem";
import { Abi, AbiParameter, AbiParametersToPrimitiveTypes, AbiConstructor } from "abitype";

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

const deployContract = async <TAbi extends Abi>({ abi, args, bytecode }: DeployContractArgs<TAbi>) => {
  const hash = await walletClient.deployContract({
    abi: abi as Abi,
    args: args as AbiParameter[],
    bytecode,
    account: ALICE,
  });

  const receipt = await publicClient.waitForTransactionReceipt({
    hash,
  });

  // rome-ignore lint/style/noNonNullAssertion: this is guaranteed to be set.
  const address = getAddress(receipt.contractAddress!);

  return address;
};

export { deployContract };
