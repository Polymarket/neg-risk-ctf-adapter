import { createPublicClient, createWalletClient, http } from "viem";
import type { PublicClient, WalletClient, Chain, Transport } from "viem";
import { polygonMumbai } from "viem/chains";

const transport = http(process.env.RPC_MUMBAI);

const publicClient: PublicClient<Transport, Chain> = createPublicClient({
  chain: polygonMumbai,
  transport,
});

const walletClient: WalletClient<Transport, Chain> = createWalletClient({
  chain: polygonMumbai,
  transport,
});

export { publicClient, walletClient };
