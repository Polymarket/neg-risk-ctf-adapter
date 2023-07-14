///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Vault
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const vault = {
  abi: [
    {
      inputs: [],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      inputs: [],
      name: "NotAdmin",
      type: "error",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "admin",
          type: "address",
        },
        {
          indexed: true,
          internalType: "address",
          name: "newAdminAddress",
          type: "address",
        },
      ],
      name: "NewAdmin",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "address",
          name: "admin",
          type: "address",
        },
        {
          indexed: true,
          internalType: "address",
          name: "removedAdmin",
          type: "address",
        },
      ],
      name: "RemovedAdmin",
      type: "event",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "admin",
          type: "address",
        },
      ],
      name: "addAdmin",
      outputs: [],
      stateMutability: "nonpayable",
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
      name: "admins",
      outputs: [
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_erc1155",
          type: "address",
        },
        {
          internalType: "address",
          name: "_to",
          type: "address",
        },
        {
          internalType: "uint256[]",
          name: "_ids",
          type: "uint256[]",
        },
        {
          internalType: "uint256[]",
          name: "_values",
          type: "uint256[]",
        },
      ],
      name: "batchTransferERC1155",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "addr",
          type: "address",
        },
      ],
      name: "isAdmin",
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
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
        },
        {
          internalType: "address",
          name: "",
          type: "address",
        },
        {
          internalType: "uint256[]",
          name: "",
          type: "uint256[]",
        },
        {
          internalType: "uint256[]",
          name: "",
          type: "uint256[]",
        },
        {
          internalType: "bytes",
          name: "",
          type: "bytes",
        },
      ],
      name: "onERC1155BatchReceived",
      outputs: [
        {
          internalType: "bytes4",
          name: "",
          type: "bytes4",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "",
          type: "address",
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
      name: "onERC1155Received",
      outputs: [
        {
          internalType: "bytes4",
          name: "",
          type: "bytes4",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "admin",
          type: "address",
        },
      ],
      name: "removeAdmin",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "renounceAdmin",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_erc1155",
          type: "address",
        },
        {
          internalType: "address",
          name: "_to",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_id",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "_value",
          type: "uint256",
        },
      ],
      name: "transferERC1155",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "address",
          name: "_erc20",
          type: "address",
        },
        {
          internalType: "address",
          name: "_to",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "_amount",
          type: "uint256",
        },
      ],
      name: "transferERC20",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
  bytecode:
    "0x608060405234801561001057600080fd5b503360009081526020819052604090206001905561090d806100336000396000f3fe608060405234801561001057600080fd5b506004361061009e5760003560e01c80638bad0c0a116100665780638bad0c0a1461014d5780639db5dbe414610155578063a9412a5914610168578063bc197c811461017b578063f23a6e61146101b657600080fd5b80630a7e880c146100a35780631785f53c146100b857806324d7806c146100cb578063429b62e51461010c578063704802751461013a575b600080fd5b6100b66100b1366004610544565b6101d6565b005b6100b66100c6366004610586565b610289565b6100f76100d9366004610586565b6001600160a01b031660009081526020819052604090205460011490565b60405190151581526020015b60405180910390f35b61012c61011a366004610586565b60006020819052908152604090205481565b604051908152602001610103565b6100b6610148366004610586565b6102fe565b6100b6610374565b6100b66101633660046105a8565b6103df565b6100b6610176366004610630565b610488565b61019d610189366004610703565b63bc197c8160e01b98975050505050505050565b6040516001600160e01b03199091168152602001610103565b61019d6101c43660046107be565b63f23a6e6160e01b9695505050505050565b3360009081526020819052604090205460011461020657604051637bfa4b9f60e01b815260040160405180910390fd5b604051637921219560e11b81523060048201526001600160a01b038481166024830152604482018490526064820183905260a06084830152600060a483015285169063f242432a9060c401600060405180830381600087803b15801561026b57600080fd5b505af115801561027f573d6000803e3d6000fd5b5050505050505050565b336000908152602081905260409020546001146102b957604051637bfa4b9f60e01b815260040160405180910390fd5b6001600160a01b0381166000818152602081905260408082208290555133917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a350565b3360009081526020819052604090205460011461032e57604051637bfa4b9f60e01b815260040160405180910390fd5b6001600160a01b038116600081815260208190526040808220600190555133917ff9ffabca9c8276e99321725bcb43fb076a6c66a54b7f21c4e8146d8519b417dc91a350565b336000908152602081905260409020546001146103a457604051637bfa4b9f60e01b815260040160405180910390fd5b336000818152602081905260408082208290555182917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a3565b3360009081526020819052604090205460011461040f57604051637bfa4b9f60e01b815260040160405180910390fd5b60405163a9059cbb60e01b81526001600160a01b0383811660048301526024820183905284169063a9059cbb906044016020604051808303816000875af115801561045e573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906104829190610824565b50505050565b336000908152602081905260409020546001146104b857604051637bfa4b9f60e01b815260040160405180910390fd5b604051631759616b60e11b81526001600160a01b03871690632eb2c2d6906104ee90309089908990899089908990600401610878565b600060405180830381600087803b15801561050857600080fd5b505af115801561051c573d6000803e3d6000fd5b50505050505050505050565b80356001600160a01b038116811461053f57600080fd5b919050565b6000806000806080858703121561055a57600080fd5b61056385610528565b935061057160208601610528565b93969395505050506040820135916060013590565b60006020828403121561059857600080fd5b6105a182610528565b9392505050565b6000806000606084860312156105bd57600080fd5b6105c684610528565b92506105d460208501610528565b9150604084013590509250925092565b60008083601f8401126105f657600080fd5b50813567ffffffffffffffff81111561060e57600080fd5b6020830191508360208260051b850101111561062957600080fd5b9250929050565b6000806000806000806080878903121561064957600080fd5b61065287610528565b955061066060208801610528565b9450604087013567ffffffffffffffff8082111561067d57600080fd5b6106898a838b016105e4565b909650945060608901359150808211156106a257600080fd5b506106af89828a016105e4565b979a9699509497509295939492505050565b60008083601f8401126106d357600080fd5b50813567ffffffffffffffff8111156106eb57600080fd5b60208301915083602082850101111561062957600080fd5b60008060008060008060008060a0898b03121561071f57600080fd5b61072889610528565b975061073660208a01610528565b9650604089013567ffffffffffffffff8082111561075357600080fd5b61075f8c838d016105e4565b909850965060608b013591508082111561077857600080fd5b6107848c838d016105e4565b909650945060808b013591508082111561079d57600080fd5b506107aa8b828c016106c1565b999c989b5096995094979396929594505050565b60008060008060008060a087890312156107d757600080fd5b6107e087610528565b95506107ee60208801610528565b94506040870135935060608701359250608087013567ffffffffffffffff81111561081857600080fd5b6106af89828a016106c1565b60006020828403121561083657600080fd5b815180151581146105a157600080fd5b81835260006001600160fb1b0383111561085f57600080fd5b8260051b80836020870137939093016020019392505050565b6001600160a01b0387811682528616602082015260a0604082018190526000906108a59083018688610846565b82810360608401526108b8818587610846565b838103608090940193909352505060008152602001969550505050505056fea26469706673582212208bd8b90cfd12cb7b312024fb9f1e6410a2a95c7e353055b969a15659757a8e3964736f6c63430008130033",
} as const;
