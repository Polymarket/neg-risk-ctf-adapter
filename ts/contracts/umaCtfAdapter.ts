//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// UmaCtfAdapter
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

export const umaCtfAdapterContract = {
  abi: [
    {
      inputs: [
        {
          internalType: "address",
          name: "_ctf",
          type: "address",
        },
        {
          internalType: "address",
          name: "_finder",
          type: "address",
        },
      ],
      stateMutability: "nonpayable",
      type: "constructor",
    },
    {
      inputs: [],
      name: "Flagged",
      type: "error",
    },
    {
      inputs: [],
      name: "Initialized",
      type: "error",
    },
    {
      inputs: [],
      name: "InvalidAncillaryData",
      type: "error",
    },
    {
      inputs: [],
      name: "InvalidOOPrice",
      type: "error",
    },
    {
      inputs: [],
      name: "InvalidPayouts",
      type: "error",
    },
    {
      inputs: [],
      name: "NotAdmin",
      type: "error",
    },
    {
      inputs: [],
      name: "NotFlagged",
      type: "error",
    },
    {
      inputs: [],
      name: "NotInitialized",
      type: "error",
    },
    {
      inputs: [],
      name: "NotOptimisticOracle",
      type: "error",
    },
    {
      inputs: [],
      name: "NotReadyToResolve",
      type: "error",
    },
    {
      inputs: [],
      name: "Paused",
      type: "error",
    },
    {
      inputs: [],
      name: "PriceNotAvailable",
      type: "error",
    },
    {
      inputs: [],
      name: "Resolved",
      type: "error",
    },
    {
      inputs: [],
      name: "SafetyPeriodNotPassed",
      type: "error",
    },
    {
      inputs: [],
      name: "UnsupportedToken",
      type: "error",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
        {
          indexed: true,
          internalType: "address",
          name: "owner",
          type: "address",
        },
        {
          indexed: false,
          internalType: "bytes",
          name: "update",
          type: "bytes",
        },
      ],
      name: "AncillaryDataUpdated",
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
          name: "questionID",
          type: "bytes32",
        },
        {
          indexed: false,
          internalType: "uint256[]",
          name: "payouts",
          type: "uint256[]",
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
          name: "questionID",
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
          name: "questionID",
          type: "bytes32",
        },
        {
          indexed: true,
          internalType: "uint256",
          name: "requestTimestamp",
          type: "uint256",
        },
        {
          indexed: true,
          internalType: "address",
          name: "creator",
          type: "address",
        },
        {
          indexed: false,
          internalType: "bytes",
          name: "ancillaryData",
          type: "bytes",
        },
        {
          indexed: false,
          internalType: "address",
          name: "rewardToken",
          type: "address",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "reward",
          type: "uint256",
        },
        {
          indexed: false,
          internalType: "uint256",
          name: "proposalBond",
          type: "uint256",
        },
      ],
      name: "QuestionInitialized",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "QuestionPaused",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "QuestionReset",
      type: "event",
    },
    {
      anonymous: false,
      inputs: [
        {
          indexed: true,
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
        {
          indexed: true,
          internalType: "int256",
          name: "settledPrice",
          type: "int256",
        },
        {
          indexed: false,
          internalType: "uint256[]",
          name: "payouts",
          type: "uint256[]",
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
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "QuestionUnpaused",
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
      inputs: [],
      name: "collateralWhitelist",
      outputs: [
        {
          internalType: "contract IAddressWhitelist",
          name: "",
          type: "address",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "ctf",
      outputs: [
        {
          internalType: "contract IConditionalTokens",
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
          name: "questionID",
          type: "bytes32",
        },
        {
          internalType: "uint256[]",
          name: "payouts",
          type: "uint256[]",
        },
      ],
      name: "emergencyResolve",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [],
      name: "emergencySafetyPeriod",
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
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "flag",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "getExpectedPayouts",
      outputs: [
        {
          internalType: "uint256[]",
          name: "",
          type: "uint256[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
        {
          internalType: "address",
          name: "owner",
          type: "address",
        },
      ],
      name: "getLatestUpdate",
      outputs: [
        {
          components: [
            {
              internalType: "uint256",
              name: "timestamp",
              type: "uint256",
            },
            {
              internalType: "bytes",
              name: "update",
              type: "bytes",
            },
          ],
          internalType: "struct AncillaryDataUpdate",
          name: "",
          type: "tuple",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "getQuestion",
      outputs: [
        {
          components: [
            {
              internalType: "uint256",
              name: "requestTimestamp",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "reward",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "proposalBond",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "liveness",
              type: "uint256",
            },
            {
              internalType: "uint256",
              name: "emergencyResolutionTimestamp",
              type: "uint256",
            },
            {
              internalType: "bool",
              name: "resolved",
              type: "bool",
            },
            {
              internalType: "bool",
              name: "paused",
              type: "bool",
            },
            {
              internalType: "bool",
              name: "reset",
              type: "bool",
            },
            {
              internalType: "address",
              name: "rewardToken",
              type: "address",
            },
            {
              internalType: "address",
              name: "creator",
              type: "address",
            },
            {
              internalType: "bytes",
              name: "ancillaryData",
              type: "bytes",
            },
          ],
          internalType: "struct QuestionData",
          name: "",
          type: "tuple",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
        {
          internalType: "address",
          name: "owner",
          type: "address",
        },
      ],
      name: "getUpdates",
      outputs: [
        {
          components: [
            {
              internalType: "uint256",
              name: "timestamp",
              type: "uint256",
            },
            {
              internalType: "bytes",
              name: "update",
              type: "bytes",
            },
          ],
          internalType: "struct AncillaryDataUpdate[]",
          name: "",
          type: "tuple[]",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes",
          name: "ancillaryData",
          type: "bytes",
        },
        {
          internalType: "address",
          name: "rewardToken",
          type: "address",
        },
        {
          internalType: "uint256",
          name: "reward",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "proposalBond",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "liveness",
          type: "uint256",
        },
      ],
      name: "initialize",
      outputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
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
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "isFlagged",
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
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "isInitialized",
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
      name: "maxAncillaryData",
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
      name: "optimisticOracle",
      outputs: [
        {
          internalType: "contract IOptimisticOracleV2",
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
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "pause",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
        {
          internalType: "bytes",
          name: "update",
          type: "bytes",
        },
      ],
      name: "postUpdate",
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
          name: "ancillaryData",
          type: "bytes",
        },
        {
          internalType: "uint256",
          name: "",
          type: "uint256",
        },
      ],
      name: "priceDisputed",
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
      ],
      name: "questions",
      outputs: [
        {
          internalType: "uint256",
          name: "requestTimestamp",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "reward",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "proposalBond",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "liveness",
          type: "uint256",
        },
        {
          internalType: "uint256",
          name: "emergencyResolutionTimestamp",
          type: "uint256",
        },
        {
          internalType: "bool",
          name: "resolved",
          type: "bool",
        },
        {
          internalType: "bool",
          name: "paused",
          type: "bool",
        },
        {
          internalType: "bool",
          name: "reset",
          type: "bool",
        },
        {
          internalType: "address",
          name: "rewardToken",
          type: "address",
        },
        {
          internalType: "address",
          name: "creator",
          type: "address",
        },
        {
          internalType: "bytes",
          name: "ancillaryData",
          type: "bytes",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "ready",
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
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "reset",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "resolve",
      outputs: [],
      stateMutability: "nonpayable",
      type: "function",
    },
    {
      inputs: [
        {
          internalType: "bytes32",
          name: "questionID",
          type: "bytes32",
        },
      ],
      name: "unpause",
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
      ],
      name: "updates",
      outputs: [
        {
          internalType: "uint256",
          name: "timestamp",
          type: "uint256",
        },
        {
          internalType: "bytes",
          name: "update",
          type: "bytes",
        },
      ],
      stateMutability: "view",
      type: "function",
    },
    {
      inputs: [],
      name: "yesOrNoIdentifier",
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
  ],
  bytecode:
    "0x60e06040523480156200001157600080fd5b5060405162003b5738038062003b5783398101604081905262000034916200019a565b33600090815260208190526040908190206001908190556002556001600160a01b0383811660805290516302abf57960e61b81527127b83a34b6b4b9ba34b1a7b930b1b632ab1960711b6004820152829182169063aafd5e4090602401602060405180830381865afa158015620000af573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190620000d59190620001d2565b6001600160a01b0390811660a0526040516302abf57960e61b81527f436f6c6c61746572616c57686974656c6973740000000000000000000000000060048201529082169063aafd5e4090602401602060405180830381865afa15801562000141573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190620001679190620001d2565b6001600160a01b031660c05250620001f7915050565b80516001600160a01b03811681146200019557600080fd5b919050565b60008060408385031215620001ae57600080fd5b620001b9836200017d565b9150620001c9602084016200017d565b90509250929050565b600060208284031215620001e557600080fd5b620001f0826200017d565b9392505050565b60805160a05160c0516138c76200029060003960008181610495015261078a01526000818161023a0152818161060801528181610bce01528181611e0c01528181611ec501528181611f9f0152818161207d015281816121430152818161221e01528181612301015281816123d501526125f60152600081816102860152818161092d015281816116b8015261274501526138c76000f3fe608060405234801561001057600080fd5b50600436106101cf5760003560e01c80637048027511610104578063c0cab0a2116100a2578063ed3c7d4011610071578063ed3c7d40146104b7578063ed56531a146104ca578063f7b637bb146104dd578063fcac49a2146104f057600080fd5b8063c0cab0a21461043f578063c66d4c6c1461045f578063dddb468014610469578063e4ee614a1461049057600080fd5b80638bad0c0a116100de5780638bad0c0a146103e757806395addb90146103ef5780639ce7c0e014610419578063bf2dde381461042c57600080fd5b806370480275146103a057806378165a48146103b357806389ab0871146103c657600080fd5b80632f4dae9f11610171578063555c56fc1161014b578063555c56fc1461034457806358c039cd146103645780635c23bdf5146103845780636b5acc631461039757600080fd5b80632f4dae9f146102f157806334e5e28e14610304578063429b62e51461032457600080fd5b8063185d1646116101ad578063185d16461461020f578063223029221461023557806322a9339f1461028157806324d7806c146102a857600080fd5b8063072d1259146101d45780630d8f2372146101e95780631785f53c146101fc575b600080fd5b6101e76101e2366004612c46565b610503565b005b6101e76101f7366004612c8d565b6105f0565b6101e761020a366004612d0a565b6106a7565b61022261021d366004612d2e565b610742565b6040519081526020015b60405180910390f35b61025c7f000000000000000000000000000000000000000000000000000000000000000081565b60405173ffffffffffffffffffffffffffffffffffffffff909116815260200161022c565b61025c7f000000000000000000000000000000000000000000000000000000000000000081565b6102e16102b6366004612d0a565b73ffffffffffffffffffffffffffffffffffffffff1660009081526020819052604090205460011490565b604051901515815260200161022c565b6101e76102ff366004612d98565b610a0e565b610317610312366004612d98565b610afd565b60405161022c9190612dec565b610222610332366004612d0a565b60006020819052908152604090205481565b610357610352366004612dff565b610c83565b60405161022c9190612ec4565b610377610372366004612d98565b610dda565b60405161022c9190612f44565b6101e7610392366004612d98565b610fb4565b610222611fcb81565b6101e76103ae366004612d0a565b6110d1565b6101e76103c1366004612d98565b61116d565b6103d96103d436600461301c565b6112ae565b60405161022c92919061303e565b6101e7611377565b6104026103fd366004612d98565b6113fb565b60405161022c9b9a99989796959493929190613057565b6101e76104273660046130dc565b611505565b6102e161043a366004612d98565b611763565b61045261044d366004612dff565b61177c565b60405161022c919061315b565b6102226202a30081565b6102227f5945535f4f525f4e4f5f5155455259000000000000000000000000000000000081565b61025c7f000000000000000000000000000000000000000000000000000000000000000081565b6101e76104c5366004612d98565b611805565b6101e76104d8366004612d98565b6118e5565b6102e16104eb366004612d98565b6119d8565b6102e16104fe366004612d98565b6119ef565b60408051602081018490523391810191909152600090606001604080517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08184030181528282528051602091820120600081815260018084528482208686019095524286528584018881528554808301875595835293909120855160029095020193845591519094509082019061059a9082613207565b5050503373ffffffffffffffffffffffffffffffffffffffff16837e59e11815211969c0c4aaf3f498b52b6c2f2d14f286275d0862d70de22a836b846040516105e39190613321565b60405180910390a3505050565b3373ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000161461065f576040517f05cef85500000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8151602080840191909120600081815260039092526040909120600581015462010000900460ff16156106935750506106a1565b61069e308383611a06565b50505b50505050565b336000908152602081905260409020546001146106f0576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b73ffffffffffffffffffffffffffffffffffffffff81166000818152602081905260408082208290555133917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a350565b6040517f3a3ab67200000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff85811660048301526000917f000000000000000000000000000000000000000000000000000000000000000090911690633a3ab67290602401602060405180830381865afa1580156107d3573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906107f79190613349565b61082d576040517f6a17288200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60006108393388611b39565b905086516000148061084d5750611fcb8151115b15610884576040517f9702d51200000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b808051906020012091506108a960036000848152602001908152602001600020611ba4565b156108e0576040517f5daa87a000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b426108f1338484848b8b8b8b611bc0565b6040517fd96ee75400000000000000000000000000000000000000000000000000000000815230600482015260248101849052600260448201527f000000000000000000000000000000000000000000000000000000000000000073ffffffffffffffffffffffffffffffffffffffff169063d96ee75490606401600060405180830381600087803b15801561098657600080fd5b505af115801561099a573d6000803e3d6000fd5b505050506109ad3382848a8a8a8a611d9a565b3373ffffffffffffffffffffffffffffffffffffffff1681847feee0897acd6893adcaf2ba5158191b3601098ab6bece35c5d57874340b64c5b7858b8b8b6040516109fb9493929190613364565b60405180910390a4505095945050505050565b33600090815260208190526040902054600114610a57576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6000818152600360205260409020610a6e81611ba4565b610aa4576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6005810180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff16905560405182907f92d28918c5574e7fc0f4f948c39502682c81cfb4089b07b83f95b3264e5e5e0690600090a25050565b6000818152600360205260409020606090610b1781611ba4565b610b4d576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b610b5681612393565b610b8c576040517f579a480100000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b80546040517fa9904f9b00000000000000000000000000000000000000000000000000000000815260009173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169163a9904f9b91610c2a9130917f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000916007890190600401613444565b61020060405180830381865afa158015610c48573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610c6c9190613539565b60c001519050610c7b81612472565b949350505050565b6060600160008484604051602001610cbb92919091825273ffffffffffffffffffffffffffffffffffffffff16602082015260400190565b604051602081830303815290604052805190602001208152602001908152602001600020805480602002602001604051908101604052809291908181526020016000905b82821015610dcd578382906000526020600020906002020160405180604001604052908160008201548152602001600182018054610d3c9061316e565b80601f0160208091040260200160405190810160405280929190818152602001828054610d689061316e565b8015610db55780601f10610d8a57610100808354040283529160200191610db5565b820191906000526020600020905b815481529060010190602001808311610d9857829003601f168201915b50505050508152505081526020019060010190610cff565b5050505090505b92915050565b610e696040518061016001604052806000815260200160008152602001600081526020016000815260200160008152602001600015158152602001600015158152602001600015158152602001600073ffffffffffffffffffffffffffffffffffffffff168152602001600073ffffffffffffffffffffffffffffffffffffffff168152602001606081525090565b6000828152600360208181526040928390208351610160810185528154815260018201549281019290925260028101549382019390935290820154606082015260048201546080820152600582015460ff808216151560a08401526101008083048216151560c0850152620100008304909116151560e084015273ffffffffffffffffffffffffffffffffffffffff630100000090920482169083015260068301541661012082015260078201805491929161014084019190610f2b9061316e565b80601f0160208091040260200160405190810160405280929190818152602001828054610f579061316e565b8015610fa45780601f10610f7957610100808354040283529160200191610fa4565b820191906000526020600020905b815481529060010190602001808311610f8757829003601f168201915b5050505050815250509050919050565b6000818152600360205260409020610fcb81611ba4565b611001576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6005810154610100900460ff1615611045576040517f9e87fac800000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600581015460ff1615611084576040517fea00f1a000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b61108d81612393565b6110c3576040517fb488fe4b00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6110cd82826125b4565b5050565b3360009081526020819052604090205460011461111a576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b73ffffffffffffffffffffffffffffffffffffffff8116600081815260208190526040808220600190555133917ff9ffabca9c8276e99321725bcb43fb076a6c66a54b7f21c4e8146d8519b417dc91a350565b336000908152602081905260409020546001146111b6576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60008181526003602052604090206111cd81611ba4565b611203576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b60048101541561123f576040517fe8e3a25900000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b61124c6202a30042613613565b60048201556005810180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff1661010017905560405182907f2435a0347185933b12027c6f394a5fd9c03646dba233e956f50658719dfc0b3590600090a25050565b600160205281600052604060002081815481106112ca57600080fd5b9060005260206000209060020201600091509150508060000154908060010180546112f49061316e565b80601f01602080910402602001604051908101604052809291908181526020018280546113209061316e565b801561136d5780601f106113425761010080835404028352916020019161136d565b820191906000526020600020905b81548152906001019060200180831161135057829003601f168201915b5050505050905082565b336000908152602081905260409020546001146113c0576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b336000818152602081905260408082208290555182917f787a2e12f4a55b658b8f573c32432ee11a5e8b51677d1e1e937aaf6a0bb5776e91a3565b6003602081905260009182526040909120805460018201546002830154938301546004840154600585015460068601546007870180549698959795969495939460ff8085169561010086048216956201000081049092169473ffffffffffffffffffffffffffffffffffffffff63010000009093048316949216929091906114829061316e565b80601f01602080910402602001604051908101604052809291908181526020018280546114ae9061316e565b80156114fb5780601f106114d0576101008083540402835291602001916114fb565b820191906000526020600020905b8154815290600101906020018083116114de57829003601f168201915b505050505090508b565b3360009081526020819052604090205460011461154e576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600083815260036020526040902060028214611596576040517f663493a000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b61159f81611ba4565b6115d5576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6004810154611610576040517fbb825d1800000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b806004015442101561164e576040517f2a2c257c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6005810180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660011790556040517fc49298ac00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169063c49298ac906116f19087908790879060040161367a565b600060405180830381600087803b15801561170b57600080fd5b505af115801561171f573d6000803e3d6000fd5b50505050837f6edb5841a476c9c29c34a652d1a44f785fe71a6157a3da9a6a6a589a1bd2945a848460405161175592919061369d565b60405180910390a250505050565b6000818152600360205260408120600401541515610dd4565b604080518082019091526000815260606020820152600061179d8484610c83565b905080516000036117d55760405180604001604052806000815260200160405180602001604052806000815250815250915050610dd4565b80600182516117e491906136b1565b815181106117f4576117f46136c8565b602002602001015191505092915050565b3360009081526020819052604090205460011461184e576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600081815260036020526040902061186581611ba4565b61189b576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600581015460ff16156118da576040517fea00f1a000000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6110cd338383611a06565b3360009081526020819052604090205460011461192e576040517f7bfa4b9f00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b600081815260036020526040902061194581611ba4565b61197b576040517f87138d5c00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b6005810180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ff1661010017905560405182907f6ded7250a9d5f79aef5add44600fc20a74a0af6f4730baa4fc4ab87bf484b81290600090a25050565b6000818152600360205260408120610dd490611ba4565b6000818152600360205260408120610dd4906127ed565b428082556005820180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00ffff1662010000179055600782018054611b08918691849190611a519061316e565b80601f0160208091040260200160405190810160405280929190818152602001828054611a7d9061316e565b8015611aca5780601f10611a9f57610100808354040283529160200191611aca565b820191906000526020600020905b815481529060010190602001808311611aad57829003601f168201915b50505050508560050160039054906101000a900473ffffffffffffffffffffffffffffffffffffffff16866001015487600201548860030154611d9a565b60405183907f7981b5832932948db4e32a4a16a0f44b2ce7ff088574afb9364b313f70f82e8f90600090a250505050565b6060816040518060400160405280600d81526020017f2c696e697469616c697a65723a00000000000000000000000000000000000000815250611b7b8561283c565b604051602001611b8d939291906136f7565b604051602081830303815290604052905092915050565b600080826007018054611bb69061316e565b9050119050919050565b604051806101600160405280868152602001848152602001838152602001828152602001600081526020016000151581526020016000151581526020016000151581526020018573ffffffffffffffffffffffffffffffffffffffff1681526020018973ffffffffffffffffffffffffffffffffffffffff1681526020018781525060036000898152602001908152602001600020600082015181600001556020820151816001015560408201518160020155606082015181600301556080820151816004015560a08201518160050160006101000a81548160ff02191690831515021790555060c08201518160050160016101000a81548160ff02191690831515021790555060e08201518160050160026101000a81548160ff0219169083151502179055506101008201518160050160036101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506101208201518160060160006101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff160217905550610140820151816007019081611d8d9190613207565b5050505050505050505050565b8215611f625773ffffffffffffffffffffffffffffffffffffffff87163014611dc957611dc9848830866128ca565b6040517fdd62ed3e00000000000000000000000000000000000000000000000000000000815230600482015273ffffffffffffffffffffffffffffffffffffffff7f00000000000000000000000000000000000000000000000000000000000000008116602483015284919086169063dd62ed3e90604401602060405180830381865afa158015611e5e573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611e82919061373a565b1015611f62576040517f095ea7b300000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000811660048301527fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff602483015285169063095ea7b3906044016020604051808303816000875af1158015611f3c573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190611f609190613349565b505b6040517f11df92f100000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f000000000000000000000000000000000000000000000000000000000000000016906311df92f190611ffc907f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000908a908a908a908a90600401613753565b6020604051808303816000875af115801561201b573d6000803e3d6000fd5b505050506040513d601f19601f8201168201806040525081019061203f919061373a565b506040517f120698af00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169063120698af906120d6907f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000908a908a9060040161379c565b600060405180830381600087803b1580156120f057600080fd5b505af1158015612104573d6000803e3d6000fd5b50506040517ff327b07500000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f000000000000000000000000000000000000000000000000000000000000000016925063f327b07591506121a6907f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000908a908a9060009060019082906004016137bb565b600060405180830381600087803b1580156121c057600080fd5b505af11580156121d4573d6000803e3d6000fd5b5050505060008211156122be576040517fad5a755a00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169063ad5a755a90612279907f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000908a908a9088906004016137fa565b6020604051808303816000875af1158015612298573d6000803e3d6000fd5b505050506040513d601f19601f820116820180604052508101906122bc919061373a565b505b801561238a576040517f473c45fe00000000000000000000000000000000000000000000000000000000815273ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169063473c45fe9061235c907f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000908a908a9087906004016137fa565b600060405180830381600087803b15801561237657600080fd5b505af1158015611d8d573d6000803e3d6000fd5b50505050505050565b80546040517fbc58ccaa00000000000000000000000000000000000000000000000000000000815260009173ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169163bc58ccaa916124319130917f5945535f4f525f4e4f5f51554552590000000000000000000000000000000000916007890190600401613444565b602060405180830381865afa15801561244e573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190610dd49190613349565b6040805160028082526060808301845292600092919060208301908036833701905050905082158015906124ae5750826706f05b59d3b2000014155b80156124c2575082670de0b6b3a764000014155b156124f9576040517f86c9649e00000000000000000000000000000000000000000000000000000000815260040160405180910390fd5b8260000361254857600081600081518110612516576125166136c8565b602002602001018181525050600181600181518110612537576125376136c8565b602002602001018181525050610dd4565b826706f05b59d3b200000361256c57600181600081518110612516576125166136c8565b600181600081518110612581576125816136c8565b6020026020010181815250506000816001815181106125a2576125a26136c8565b60200260200101818152505092915050565b80546040517f53b5923900000000000000000000000000000000000000000000000000000000815260009173ffffffffffffffffffffffffffffffffffffffff7f000000000000000000000000000000000000000000000000000000000000000016916353b5923991612651917f5945535f4f525f4e4f5f515545525900000000000000000000000000000000009190600788019060040161382a565b6020604051808303816000875af1158015612670573d6000803e3d6000fd5b505050506040513d601f19601f82011682018060405250810190612694919061373a565b90507f800000000000000000000000000000000000000000000000000000000000000081036126cd576126c8308484611a06565b505050565b60006126d882612472565b6005840180547fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff001660011790556040517fc49298ac00000000000000000000000000000000000000000000000000000000815290915073ffffffffffffffffffffffffffffffffffffffff7f0000000000000000000000000000000000000000000000000000000000000000169063c49298ac9061277c9087908590600401613849565b600060405180830381600087803b15801561279657600080fd5b505af11580156127aa573d6000803e3d6000fd5b5050505081847f566c3fbdd12dd86bb341787f6d531f79fd7ad4ce7e3ae2d15ac0ca1b601af9df836040516127df9190612dec565b60405180910390a350505050565b60006127f882611ba4565b61280457506000919050565b6005820154610100900460ff161561281e57506000919050565b600582015460ff161561283357506000919050565b610dd482612393565b606061285d6fffffffffffffffffffffffffffffffff602084901c166128d6565b6128788360601b6bffffffffffffffffffffffff19166128d6565b6040516020016128b49291909182527fffffffffffffffff00000000000000000000000000000000000000000000000016602082015260280190565b6040516020818303038152906040529050919050565b6106a184848484612a78565b6000808260001c9050806fffffffffffffffffffffffffffffffff169050806801000000000000000002811777ffffffffffffffff0000000000000000ffffffffffffffff169050806401000000000281177bffffffff00000000ffffffff00000000ffffffff00000000ffffffff16905080620100000281177dffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff169050806101000281177eff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff1690508060100281177f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f16905060006008827f080808080808080808080808080808080808080808080808080808080808080816816129fa576129fa613862565b0460047f040404040404040404040404040404040404040404040404040404040404040484160460027f020202020202020202020202020202020202020202020202020202020202020285160417166027029091017f3030303030303030303030303030303030303030303030303030303030303030019392505050565b60006040517f23b872dd0000000000000000000000000000000000000000000000000000000081528460048201528360248201528260448201526020600060648360008a5af13d15601f3d1160016000511416171691505080612b3b576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601460248201527f5452414e534645525f46524f4d5f4641494c4544000000000000000000000000604482015260640160405180910390fd5b5050505050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b604051610140810167ffffffffffffffff81118282101715612b9557612b95612b42565b60405290565b600082601f830112612bac57600080fd5b813567ffffffffffffffff80821115612bc757612bc7612b42565b604051601f83017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0908116603f01168101908282118183101715612c0d57612c0d612b42565b81604052838152866020858801011115612c2657600080fd5b836020870160208301376000602085830101528094505050505092915050565b60008060408385031215612c5957600080fd5b82359150602083013567ffffffffffffffff811115612c7757600080fd5b612c8385828601612b9b565b9150509250929050565b60008060008060808587031215612ca357600080fd5b8435935060208501359250604085013567ffffffffffffffff811115612cc857600080fd5b612cd487828801612b9b565b949793965093946060013593505050565b73ffffffffffffffffffffffffffffffffffffffff81168114612d0757600080fd5b50565b600060208284031215612d1c57600080fd5b8135612d2781612ce5565b9392505050565b600080600080600060a08688031215612d4657600080fd5b853567ffffffffffffffff811115612d5d57600080fd5b612d6988828901612b9b565b9550506020860135612d7a81612ce5565b94979496505050506040830135926060810135926080909101359150565b600060208284031215612daa57600080fd5b5035919050565b600081518084526020808501945080840160005b83811015612de157815187529582019590820190600101612dc5565b509495945050505050565b602081526000612d276020830184612db1565b60008060408385031215612e1257600080fd5b823591506020830135612e2481612ce5565b809150509250929050565b60005b83811015612e4a578181015183820152602001612e32565b838111156106a15750506000910152565b60008151808452612e73816020860160208601612e2f565b601f017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169290920160200192915050565b805182526000602082015160406020850152610c7b6040850182612e5b565b6000602080830181845280855180835260408601915060408160051b870101925083870160005b82811015612f37577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffc0888603018452612f25858351612ea5565b94509285019290850190600101612eeb565b5092979650505050505050565b6020815281516020820152602082015160408201526040820151606082015260608201516080820152608082015160a0820152600060a0830151612f8c60c084018215159052565b5060c083015180151560e08401525060e0830151610100612fb08185018315159052565b8401519050610120612fd98482018373ffffffffffffffffffffffffffffffffffffffff169052565b84015190506101406130028482018373ffffffffffffffffffffffffffffffffffffffff169052565b840151610160848101529050610c7b610180840182612e5b565b6000806040838503121561302f57600080fd5b50508035926020909101359150565b828152604060208201526000610c7b6040830184612e5b565b60006101608d83528c60208401528b60408401528a606084015289608084015288151560a084015287151560c084015286151560e084015273ffffffffffffffffffffffffffffffffffffffff80871661010085015280861661012085015250806101408401526130ca81840185612e5b565b9e9d5050505050505050505050505050565b6000806000604084860312156130f157600080fd5b83359250602084013567ffffffffffffffff8082111561311057600080fd5b818601915086601f83011261312457600080fd5b81358181111561313357600080fd5b8760208260051b850101111561314857600080fd5b6020830194508093505050509250925092565b602081526000612d276020830184612ea5565b600181811c9082168061318257607f821691505b6020821081036131bb577f4e487b7100000000000000000000000000000000000000000000000000000000600052602260045260246000fd5b50919050565b601f8211156126c857600081815260208120601f850160051c810160208610156131e85750805b601f850160051c820191505b8181101561069e578281556001016131f4565b815167ffffffffffffffff81111561322157613221612b42565b6132358161322f845461316e565b846131c1565b602080601f83116001811461328857600084156132525750858301515b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff600386901b1c1916600185901b17855561069e565b6000858152602081207fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe08616915b828110156132d5578886015182559484019460019091019084016132b6565b508582101561331157878501517fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff600388901b60f8161c191681555b5050505050600190811b01905550565b602081526000612d276020830184612e5b565b8051801515811461334457600080fd5b919050565b60006020828403121561335b57600080fd5b612d2782613334565b6080815260006133776080830187612e5b565b73ffffffffffffffffffffffffffffffffffffffff959095166020830152506040810192909252606090910152919050565b600081546133b68161316e565b8085526020600183811680156133d3576001811461340b57613439565b7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff008516838901528284151560051b8901019550613439565b866000528260002060005b858110156134315781548a8201860152908301908401613416565b890184019650505b505050505092915050565b73ffffffffffffffffffffffffffffffffffffffff8516815283602082015282604082015260806060820152600061347f60808301846133a9565b9695505050505050565b805161334481612ce5565b600060e082840312156134a657600080fd5b60405160e0810181811067ffffffffffffffff821117156134c9576134c9612b42565b6040529050806134d883613334565b81526134e660208401613334565b60208201526134f760408401613334565b604082015261350860608401613334565b606082015261351960808401613334565b608082015260a083015160a082015260c083015160c08201525092915050565b6000610200828403121561354c57600080fd5b613554612b71565b61355d83613489565b815261356b60208401613489565b602082015261357c60408401613489565b604082015261358d60608401613334565b606082015261359f8460808501613494565b608082015261016083015160a082015261018083015160c08201526101a083015160e08201526101c08301516101008201526101e09092015161012083015250919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b60008219821115613626576136266135e4565b500190565b81835260007f07ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff83111561365d57600080fd5b8260051b8083602087013760009401602001938452509192915050565b83815260406020820152600061369460408301848661362b565b95945050505050565b602081526000610c7b60208301848661362b565b6000828210156136c3576136c36135e4565b500390565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b60008451613709818460208901612e2f565b84519083019061371d818360208901612e2f565b8451910190613730818360208801612e2f565b0195945050505050565b60006020828403121561374c57600080fd5b5051919050565b85815284602082015260a06040820152600061377260a0830186612e5b565b73ffffffffffffffffffffffffffffffffffffffff94909416606083015250608001529392505050565b8381528260208201526060604082015260006136946060830184612e5b565b86815285602082015260c0604082015260006137da60c0830187612e5b565b9415156060830152509115156080830152151560a0909101529392505050565b8481528360208201526080604082015260006138196080830185612e5b565b905082606083015295945050505050565b83815282602082015260606040820152600061369460608301846133a9565b828152604060208201526000610c7b6040830184612db1565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601260045260246000fdfea2646970667358221220d408fd1c7a4b85dbdfd2df4858ef71d8e785be42624fc01863eb2c8a87753b2864736f6c634300080f0033",
} as const;
