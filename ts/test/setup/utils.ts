import { createPublicClient, createTestClient, createWalletClient, http } from "viem";
import type { PublicClient, WalletClient, TestClient, Chain, Transport } from "viem";
import { polygonMumbai } from "viem/chains";

/**
 * The id of the current test worker.
 *
 * This is used by the anvil proxy to route requests to the correct anvil instance.
 */
export const pool = Number(process.env.VITEST_POOL_ID ?? 1);
const transport = http(`http://127.0.0.1:8546/${pool}`);

const testClient: TestClient = createTestClient({
  mode: "anvil",
  chain: polygonMumbai,
  transport,
});

const publicClient: PublicClient<Transport, Chain> = createPublicClient({
  chain: polygonMumbai,
  transport,
});

const walletClient: WalletClient<Transport, Chain> = createWalletClient({
  chain: polygonMumbai,
  transport,
});

export { testClient, publicClient, walletClient };
