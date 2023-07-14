///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// NegRiskOperator
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const negRiskOperator = {
  abi: [
    {
      inputs: [
        {
          internalType: "address",
          name: "_nrAdapter",
          type: "address",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      inputs: [],
      name: "DelayPeriodNotOver",
      type: "error",
    },
    {
      inputs: [],
      name: "InvalidPayouts",
      type: "error",
    },
    {
      inputs: [],
      name: "InvalidRequestId",
      type: "error",
    },
    {
      inputs: [],
      name: "NotAdmin",
      type: "error",
    },
    {
      inputs: [],
      name: "NotEligibleForEmergencyResolution",
      type: "error",
    },
    {
      inputs: [],
      name: "OnlyFlagged",
      type: "error",
    },
    {
      inputs: [],
      name: "OnlyNegRiskAdapter",
      type: "error",
    },
    {
      inputs: [],
      name: "OnlyNotFlagged",
      type: "error",
    },
    {
      inputs: [],
      name: "OnlyOracle",
      type: "error",
    },
    {
      inputs: [],
      name: "OracleAlreadyInitialized",
      type: "error",
    },
    {
      inputs: [],
      name: "QuestionAlreadyReported",
      type: "error",
    },
    {
      inputs: [],
      name: "QuestionWithRequestIdAlreadyPrepared",
      type: "error",
    },
    {
      inputs: [],
      name: "ResultNotAvailable",
      type: "error",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "marketId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "feeBips",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "bytes",
          name: "data",
          type: "bytes",
        },
      ],
      name: "MarketPrepared",
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
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "bool",
          name: "result",
          type: "bool",
        },
      ],
      name: "QuestionEmergencyResolved",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
      ],
      name: "QuestionFlagged",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "marketId",
          type: "bytes32",
        },
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
        {
          indexed: true,
          internalType: "bytes32",
          name: "requestId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "questionIndex",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "bytes",
          name: "data",
          type: "bytes",
        },
      ],
      name: "QuestionPrepared",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "bytes32",
          name: "requestId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "bool",
          name: "result",
          type: "bool",
        },
      ],
      name: "QuestionReported",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "bool",
          name: "result",
          type: "bool",
        },
      ],
      name: "QuestionResolved",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionId",
          type: "bytes32",
        },
      ],
      name: "QuestionUnflagged",
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
      stateMutability: "nonpayable",
      type: "fallback",
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
      inputs: [],
      name: "delayPeriod",
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
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
        {
          internalType: "bool",
          name: "_result",
          type: "bool",
        },
      ],
      name: "emergencyResolveQuestion",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "flagQuestion",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "flaggedAt",
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
      inputs: [],
      name: "nrAdapter",
      outputs: [
        {
          internalType: "contract NegRiskAdapter",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "oracle",
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
          internalType: "uint256",
          name: "_feeBips",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "_data",
          type: "bytes",
        },
      ],
      name: "prepareMarket",
      outputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_marketId",
          type: "bytes32",
        },
        {
          internalType: "bytes",
          name: "_data",
          type: "bytes",
        },
        {
          internalType: "bytes32",
          name: "_requestId",
          type: "bytes32",
        },
      ],
      name: "prepareQuestion",
      outputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
      ],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_requestId",
          type: "bytes32",
        },
      ],
      name: "questionIds",
      outputs: [
        {
          internalType: "bytes32",
          name: "",
          type: "bytes32",
        },
      ],
      stateMutability: "view",
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
          internalType: "bytes32",
          name: "_requestId",
          type: "bytes32",
        },
        {
          internalType: "uint256[]",
          name: "_payouts",
          type: "uint256[]",
        },
      ],
      name: "reportPayouts",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "reportedAt",
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
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "resolveQuestion",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "results",
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
          name: "_oracle",
          type: "address",
        },
      ],
      name: "setOracle",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "_questionId",
          type: "bytes32",
        },
      ],
      name: "unflagQuestion",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
  ],
  bytecode:
    "0x60a060405234801561001057600080fd5b506040516110ba3803806110ba83398101604081905261002f91610053565b336000908152602081905260409020600190556001600160a01b0316608052610083565b60006020828403121561006557600080fd5b81516001600160a01b038116811461007c57600080fd5b9392505050565b6080516110006100ba60003960008181610191015281816105050152818161078201528181610b150152610c3101526110006000f3fe608060405234801561001057600080fd5b50600436106101235760003560e01c80637b50d3b2116100a7578063b8d89e071161006e578063b8d89e07146102bf578063c49298ac146102df578063d46da3d5146102f2578063dc89a19814610305578063ead412431461032557005b80637b50d3b2146102755780637dc0d1d0146102885780638a0db6151461029b5780638bad0c0a146102ae578063b1c94d94146102b657005b80634c6b25b1116100eb5780634c6b25b1146101f95780636b942f7c1461021c5780636e88c8fd1461022f578063704802751461024f5780637adbf9731461026257005b80630aaf23fa146101255780631785f53c1461013857806324d7806c1461014b57806325c0520a1461018c578063429b62e5146101cb575b005b610123610133366004610d07565b610338565b610123610146366004610d20565b6103d1565b610177610159366004610d20565b6001600160a01b031660009081526020819052604090205460011490565b60405190151581526020015b60405180910390f35b6101b37f000000000000000000000000000000000000000000000000000000000000000081565b6040516001600160a01b039091168152602001610183565b6101eb6101d9366004610d20565b60006020819052908152604090205481565b604051908152602001610183565b610177610207366004610d07565b60036020526000908152604090205460ff1681565b61012361022a366004610d07565b610446565b6101eb61023d366004610d07565b60056020526000908152604090205481565b61012361025d366004610d20565b6105ab565b610123610270366004610d20565b610621565b610123610283366004610d07565b61069d565b6001546101b3906001600160a01b031681565b6101eb6102a9366004610d99565b610738565b610123610844565b6101eb611c2081565b6101eb6102cd366004610d07565b60046020526000908152604090205481565b6101236102ed366004610de5565b6108af565b610123610300366004610e64565b610a6b565b6101eb610313366004610d07565b60026020526000908152604090205481565b6101eb610333366004610e99565b610bba565b3360009081526020819052604090205460011461036857604051637bfa4b9f60e01b815260040160405180910390fd5b60008181526004602052604081205490036103965760405163015030c360e01b815260040160405180910390fd5b6000818152600460205260408082208290555182917f052435bc04fc49113a7bfd9198a92c0852ca622a621800f6da66d4b29b786c0591a250565b3360009081526020819052604090205460011461040157604051637bfa4b9f60e01b815260040160405180910390fd5b6001600160a01b0381166000818152602081905260408082208290555133917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a350565b600081815260046020526040902054819015610475576040516318e6a4f760e01b815260040160405180910390fd5b600082815260056020526040812054908190036104a55760405163158f17cf60e21b815260040160405180910390fd5b6104b1611c2082610f02565b4210156104d15760405163d0b72b4960e01b815260040160405180910390fd5b6000838152600360205260409081902054905163e200affd60e01b81526004810185905260ff9091168015156024830152907f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063e200affd90604401600060405180830381600087803b15801561055157600080fd5b505af1158015610565573d6000803e3d6000fd5b50505050837f5c3937ed929cd157b73b417381d743daf6e1ef65999e3ccb5dd64bc3247e28d68260405161059d911515815260200190565b60405180910390a250505050565b336000908152602081905260409020546001146105db57604051637bfa4b9f60e01b815260040160405180910390fd5b6001600160a01b038116600081815260208190526040808220600190555133917ff9ffabca9c8276e99321725bcb43fb076a6c66a54b7f21c4e8146d8519b417dc91a350565b3360009081526020819052604090205460011461065157604051637bfa4b9f60e01b815260040160405180910390fd5b6001546001600160a01b03161561067b5760405163463f746b60e11b815260040160405180910390fd5b600180546001600160a01b0319166001600160a01b0392909216919091179055565b336000908152602081905260409020546001146106cd57604051637bfa4b9f60e01b815260040160405180910390fd5b6000818152600460205260409020548190156106fc576040516318e6a4f760e01b815260040160405180910390fd5b6000828152600460205260408082204290555183917f2435a0347185933b12027c6f394a5fd9c03646dba233e956f50658719dfc0b3591a25050565b3360009081526020819052604081205460011461076857604051637bfa4b9f60e01b815260040160405180910390fd5b604051638a0db61560e01b81526000906001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001690638a0db615906107bb90889088908890600401610f44565b6020604051808303816000875af11580156107da573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107fe9190610f67565b9050807f8138c0666fe0f752ff38486f542284f127aef02642c9c8db716ee1088839eeb086868660405161083493929190610f44565b60405180910390a2949350505050565b3360009081526020819052604090205460011461087457604051637bfa4b9f60e01b815260040160405180910390fd5b336000818152602081905260408082208290555182917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a3565b6001546001600160a01b031633146108da576040516380fee10560e01b815260040160405180910390fd5b600281146108fb57604051630331a49d60e51b815260040160405180910390fd5b60008282600081811061091057610910610f80565b90506020020135905060008383600181811061092e5761092e610f80565b905060200201359050600081836109459190610f96565b118061095857506109568183610f02565b155b1561097657604051630331a49d60e51b815260040160405180910390fd5b600085815260026020526040902054806109a3576040516302e8145360e61b815260040160405180910390fd5b600081815260056020526040902054156109d05760405163565d86ef60e11b815260040160405180910390fd5b6000836001146109e15760006109e4565b60015b905042600185146109f65760006109f9565b60015b6000848152600360209081526040808320805460ff191694151594909417909355600581529082902042905581518a81528415159181019190915284917f504306b41b2531b3fd2bc5e1b32dc1fc87501906cfc63c1180e3873af20f0eae910160405180910390a25050505050505050565b33600090815260208190526040902054600114610a9b57604051637bfa4b9f60e01b815260040160405180910390fd5b60008281526004602052604081205490819003610acb5760405163015030c360e01b815260040160405180910390fd5b610ad7611c2082610f02565b421015610af75760405163d0b72b4960e01b815260040160405180910390fd5b60405163e200affd60e01b81526004810184905282151560248201527f00000000000000000000000000000000000000000000000000000000000000006001600160a01b03169063e200affd90604401600060405180830381600087803b158015610b6157600080fd5b505af1158015610b75573d6000803e3d6000fd5b50505050827fd1aea2ca9d3458614d11a93a203dd9fabbd3576aeb841422c46e235637333cb983604051610bad911515815260200190565b60405180910390a2505050565b33600090815260208190526040812054600114610bea57604051637bfa4b9f60e01b815260040160405180910390fd5b60008281526002602052604090205415610c1757604051631b32079760e11b815260040160405180910390fd5b604051631d69b48d60e01b81526000906001600160a01b037f00000000000000000000000000000000000000000000000000000000000000001690631d69b48d90610c6a90899089908990600401610f44565b6020604051808303816000875af1158015610c89573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610cad9190610f67565b600084815260026020526040902081905590508281877fcdc45423ec79c60a3fe3de57272e598d71a4ec88822e822ac8e134184a8435aa828989604051610cf693929190610fad565b60405180910390a495945050505050565b600060208284031215610d1957600080fd5b5035919050565b600060208284031215610d3257600080fd5b81356001600160a01b0381168114610d4957600080fd5b9392505050565b60008083601f840112610d6257600080fd5b50813567ffffffffffffffff811115610d7a57600080fd5b602083019150836020828501011115610d9257600080fd5b9250929050565b600080600060408486031215610dae57600080fd5b83359250602084013567ffffffffffffffff811115610dcc57600080fd5b610dd886828701610d50565b9497909650939450505050565b600080600060408486031215610dfa57600080fd5b83359250602084013567ffffffffffffffff80821115610e1957600080fd5b818601915086601f830112610e2d57600080fd5b813581811115610e3c57600080fd5b8760208260051b8501011115610e5157600080fd5b6020830194508093505050509250925092565b60008060408385031215610e7757600080fd5b8235915060208301358015158114610e8e57600080fd5b809150509250929050565b60008060008060608587031215610eaf57600080fd5b84359350602085013567ffffffffffffffff811115610ecd57600080fd5b610ed987828801610d50565b9598909750949560400135949350505050565b634e487b7160e01b600052601160045260246000fd5b80820180821115610f1557610f15610eec565b92915050565b81835281816020850137506000828201602090810191909152601f909101601f19169091010190565b838152604060208201526000610f5e604083018486610f1b565b95945050505050565b600060208284031215610f7957600080fd5b5051919050565b634e487b7160e01b600052603260045260246000fd5b8082028115828204841417610f1557610f15610eec565b60ff84168152604060208201526000610f5e604083018486610f1b56fea264697066735822122061d7981849e4fbb7015f71cb87bd92779c3d20e8919154fb2f78dda897ce254b64736f6c63430008130033",
} as const;
