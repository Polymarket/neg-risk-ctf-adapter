import dotenv from "dotenv";
import { startProxy } from "@viem/anvil";

dotenv.config();

let shutdown: () => void;

const setup = async () => {
  shutdown = await startProxy({
    port: 8546, // By default, the proxy will listen on port 8545.
    host: "::", // By default, the proxy will listen on all interfaces.
    options: {
      chainId: 80001,
      // forkUrl: process.env.RPC_MUMBAI,
    },
  });
};

const teardown = () => {
  shutdown();
  process.exit();
};

// const teardown =
// export default async function () {
//   return await startProxy({
//     port: 8546, // By default, the proxy will listen on port 8545.
//     host: "::", // By default, the proxy will listen on all interfaces.
//     options: {
//       chainId: 80001,
//       // forkUrl: process.env.RPC_MUMBAI,
//     },
//   });
// }

export { setup, teardown };
