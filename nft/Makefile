-include .env

SEPOLIA_ARGS :=  --keystore $(SEPOLIA_KEY_STORE_PATH)  \
	--rpc-url $(SEPOLIA_URL)  \
	--sender $(SEPOLIA_SENDER_ADDRESS)  \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETH_SCAN_API) \
	-vvvv \

ANVIL_ARGS :=  --private-key $(ANVIL_PRIVATE_KEY)  \
	--rpc-url $(ANVIL_RPC_URL)  \
	--broadcast \
	-vvvv \

build :; forge build

# Basic NFT

deploy-basicnft-sepolia:
	forge script script/DeployBasicNFT.s.sol $(SEPOLIA_ARGS)

mint-basicnft-sepolia:
	forge script script/Interactions.s.sol:MintBasicNFT $(SEPOLIA_ARGS)

deploy-basicnft-anvil:
	forge script script/DeployBasicNFT.s.sol $(ANVIL_ARGS)

mint-basicnft-anvil:
	forge script script/Interactions.s.sol:MintBasicNFT $(ANVIL_ARGS)

# Mood NFT

deploy-moodnft-sepolia:
	forge script script/DeployMoodNFT.s.sol $(SEPOLIA_ARGS)

mint-moodnft-sepolia:
	forge script script/Interactions.s.sol:MintBasicNFT $(SEPOLIA_ARGS)

# use this when wanting to save last deployed contract
deploy-moodnft-anvil:
	forge script script/DeployMoodNFT.s.sol $(ANVIL_ARGS)

mint-moodnft-anvil:
	forge script script/Interactions.s.sol:MintMoodNFT $(ANVIL_ARGS)

#Global

# Use this when wanting to the last deployed contract
test-anvil:
	forge test --fork-url $(ANVIL_RPC_URL) -vv

# Test only when having deployed the MoodNFT contract
test-sepolia:
	forge test --fork-url $(SEPOLIA_URL) -vv