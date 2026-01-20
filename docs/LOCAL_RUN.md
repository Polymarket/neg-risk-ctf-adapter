# Local Run Notes

This document describes how to run the Negative Risk CTF Adapter locally.

## Requirements

- Node.js 18+
- npm or yarn
- Access to an Ethereum RPC endpoint

## Steps

1. Install dependencies:
   npm install

2. Configure environment variables:
   Copy .env.example to .env and fill in the required values.

3. Compile contracts:
   npm run build

4. Run adapter:
   npm run start

## Notes

- Ensure the configured chain ID matches the RPC network.
- Use a funded test account for local testing.
