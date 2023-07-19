import type { Address, Hex } from "viem";
import { pad, keccak256, concat, toHex } from "viem";

const getMarketId = (oracle: Address, feeBips: bigint, metadata: Hex) => {
  const metadataLength = (metadata.length - 2) / 2;
  const metadataWords = Math.ceil(metadataLength / 32);

  const bytes = concat([
    pad(oracle), // negRiskOperator is the oracle
    toHex(feeBips, { size: 32 }),
    toHex(96, { size: 32 }), // memory offset
    toHex(metadataLength, { size: 32 }), // metadataLength
    pad(metadata, { dir: "right", size: metadataWords * 32 }), // pad metadata to nearest 32 byte word
  ]);

  console.log(bytes);

  const marketId = keccak256(bytes).slice(0, 64).concat("00");

  return marketId;
};

export { getMarketId };
