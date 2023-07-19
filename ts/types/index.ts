import type {
  Hex,
  GetContractReturnType,
  GetContractParameters,
  PublicClient,
  WalletClient,
  Chain,
  Transport,
} from "viem";
import type { Abi, AbiParametersToPrimitiveTypes, AbiConstructor, Address } from "abitype";

export type GetConstructorArgs<
  TAbi extends Abi | readonly unknown[],
  TAbiConstructor extends AbiConstructor = TAbi extends Abi
    ? Extract<TAbi[number], { type: "constructor" }>
    : AbiConstructor,
  TArgs = AbiParametersToPrimitiveTypes<TAbiConstructor["inputs"]>,
  FailedToParseArgs = ([TArgs] extends [never] ? true : false) | (readonly unknown[] extends TArgs ? true : false),
> = true extends FailedToParseArgs ? readonly [] : TArgs;

export type DeployContractArgs<TAbi extends Abi, TArgs = GetConstructorArgs<TAbi>> = {
  abi: TAbi;
  args: TArgs;
  bytecode: Hex;
};

export type GetContract<TAbi extends Abi, TPublicClient extends PublicClient, TWalletClient extends WalletClient> = (
  args: GetContractParameters<Transport, Chain, undefined, Abi, TPublicClient, TWalletClient, Address>,
) => Contract<TAbi, TPublicClient, TWalletClient>;

export type Contract<
  TAbi extends Abi,
  TPublicClient extends PublicClient,
  TWalletClient extends WalletClient | undefined,
> = GetContractReturnType<TAbi, TPublicClient, TWalletClient> & {
  address: Address;
};
