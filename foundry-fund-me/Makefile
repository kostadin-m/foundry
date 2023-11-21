-include .env

build :; forge build
deploy-fundme--sepolia:
	forge script script/DeployFundMe.s.sol  \
	--keystore $(SEPOLIA_KEY_STORE_PATH)  \
	--rpc-url $(SEPOLIA_URL)  \
	--sender $(SEPOLIA_SENDER_ADDRESS)  \
	--broadcast \
	--verify \
	--etherscan-api-key $(ETH_SCAN_API) \
	-vvvv \