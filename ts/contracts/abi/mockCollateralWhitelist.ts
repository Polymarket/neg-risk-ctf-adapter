///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MockCollateralWhitelist
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const mockCollateralWhitelist = {
  abi: [
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      name: "addToWhitelist",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "getWhitelist",
      outputs: [
        {
          internalType: "address[]",
          name: "",
          type: "address[]",
        },
      ],
      stateMutability: "pure",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      name: "isOnWhitelist",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "pure",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
      ],
      name: "removeFromWhitelist",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
  bytecode:
    "0x608060405234801561001057600080fd5b50610159806100206000396000f3fe608060405234801561001057600080fd5b506004361061004c5760003560e01c80633a3ab672146100515780638ab1d6811461007a578063d01f63f51461008d578063e43252d71461007a575b600080fd5b61006561005f3660046100a6565b50600190565b60405190151581526020015b60405180910390f35b61008b6100883660046100a6565b50565b005b60408051600081526020810191829052610071916100d6565b6000602082840312156100b857600080fd5b81356001600160a01b03811681146100cf57600080fd5b9392505050565b6020808252825182820181905260009190848201906040850190845b818110156101175783516001600160a01b0316835292840192918401916001016100f2565b5090969550505050505056fea26469706673582212201f94d2e8130f3c4efc8113422dd2c57597380b0ed607c1cf491ee6123defafd864736f6c63430008130033",
} as const;
