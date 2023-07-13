//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Finder
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const finder = {
  abi: [
    {
      inputs: [
        {
          internalType: "address",
          name: "_optimisticOracleV2",
          type: "address",
        },
        {
          internalType: "address",
          name: "_collateralWhitelist",
          type: "address",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      name: "changeImplementationAddress",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "collateralWhitelist",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "interfaceName",
          type: "bytes32",
        },
      ],
      name: "getImplementationAddress",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "optimisticOracleV2",
      outputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
  ],
  bytecode:
    "0x60c060405234801561001057600080fd5b506040516102bc3803806102bc83398101604081905261002f91610062565b6001600160a01b039182166080521660a052610095565b80516001600160a01b038116811461005d57600080fd5b919050565b6000806040838503121561007557600080fd5b61007e83610046565b915061008c60208401610046565b90509250929050565b60805160a0516101f66100c66000396000818160c001526101470152600081816056015261010301526101f66000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80630d2af8d31461005157806331f9665e14610094578063aafd5e40146100a8578063e4ee614a146100bb575b600080fd5b6100787f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b03909116815260200160405180910390f35b6100a66100a236600461016b565b5050565b005b6100786100b63660046101a7565b6100e2565b6100787f000000000000000000000000000000000000000000000000000000000000000081565b6000817127b83a34b6b4b9ba34b1a7b930b1b632ab1960711b0361012757507f0000000000000000000000000000000000000000000000000000000000000000919050565b817210dbdb1b185d195c985b15da1a5d195b1a5cdd606a1b0361004c57507f0000000000000000000000000000000000000000000000000000000000000000919050565b6000806040838503121561017e57600080fd5b8235915060208301356001600160a01b038116811461019c57600080fd5b809150509250929050565b6000602082840312156101b957600080fd5b503591905056fea26469706673582212205a5f00fcc424123be5fdb42b13b0150420dcd874d454870c4e3db41bb3a4290864736f6c63430008130033",
} as const;
