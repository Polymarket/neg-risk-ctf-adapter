///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// MockOptimisticOracleV2
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const mockOptimisticOracleV2 = {
  abi: [
    {
      stateMutability: "nonpayable",
      type: "fallback",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "",
          type: "bytes",
        },
      ],
      name: "hasPrice",
      outputs: [
        {
          internalType: "bool",
          name: "",
          type: "bool",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "price",
      outputs: [
        {
          internalType: "int256",
          name: "",
          type: "int256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "",
          type: "bytes",
        },
        {
          internalType: "address",
          name: "",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      name: "requestPrice",
      outputs: [
        {
          internalType: "uint256",
          name: "totalBond",
          type: "uint256",
        },
      ],
      stateMutability: "pure",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "",
          type: "bytes",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      name: "setBond",
      outputs: [
        {
          internalType: "uint256",
          name: "totalBond",
          type: "uint256",
        },
      ],
      stateMutability: "pure",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "int256",
          name: "_price",
          type: "int256",
        },
      ],
      name: "setPrice",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "",
          type: "bytes",
        },
      ],
      name: "settleAndGetPrice",
      outputs: [
        {
          internalType: "int256",
          name: "",
          type: "int256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "unsetPrice",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
  bytecode:
    "0x608060405234801561001057600080fd5b5061044a806100206000396000f3fe608060405234801561001057600080fd5b506004361061007a5760003560e01c8063ad5a755a11610058578063ad5a755a146100c9578063bc58ccaa146100e1578063c40d90bb14610104578063f7a308061461010f57005b806311df92f11461007c57806353b59239146100a8578063a035b1fe146100c0575b005b61009561008a366004610289565b600095945050505050565b6040519081526020015b60405180910390f35b6100956100b63660046102f2565b6000549392505050565b61009560005481565b6100956100d7366004610342565b6000949350505050565b6100f46100ef36600461039a565b610122565b604051901515815260200161009f565b61007a600019600055565b61007a61011d3660046103fb565b610158565b60008054158061013b57506000546706f05b59d3b20000145b8061014f5750600054670de0b6b3a7640000145b95945050505050565b600054158061017057506000546706f05b59d3b20000145b806101845750600054670de0b6b3a7640000145b1561018e57600055565b60405162461bcd60e51b815260206004820152600d60248201526c696e76616c696420707269636560981b604482015260640160405180910390fd5b634e487b7160e01b600052604160045260246000fd5b600082601f8301126101f157600080fd5b813567ffffffffffffffff8082111561020c5761020c6101ca565b604051601f8301601f19908116603f01168101908282118183101715610234576102346101ca565b8160405283815286602085880101111561024d57600080fd5b836020870160208301376000602085830101528094505050505092915050565b80356001600160a01b038116811461028457600080fd5b919050565b600080600080600060a086880312156102a157600080fd5b8535945060208601359350604086013567ffffffffffffffff8111156102c657600080fd5b6102d2888289016101e0565b9350506102e16060870161026d565b949793965091946080013592915050565b60008060006060848603121561030757600080fd5b8335925060208401359150604084013567ffffffffffffffff81111561032c57600080fd5b610338868287016101e0565b9150509250925092565b6000806000806080858703121561035857600080fd5b8435935060208501359250604085013567ffffffffffffffff81111561037d57600080fd5b610389878288016101e0565b949793965093946060013593505050565b600080600080608085870312156103b057600080fd5b6103b98561026d565b93506020850135925060408501359150606085013567ffffffffffffffff8111156103e357600080fd5b6103ef878288016101e0565b91505092959194509250565b60006020828403121561040d57600080fd5b503591905056fea2646970667358221220b3e4ae07a5b284733383a90e060fc2505a0ebfbd729d440e7d7b7c380603958564736f6c63430008130033",
} as const;
