include .env
export

.PHONY: deploy-local deploy-sepolia

# Adjust these variables as per your project setup
DEPLOY_SCRIPT = script/DeployTipJar.s.sol

# Deploy to Anvil (local testnet)
deploy-local:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(ANVIL_RPC_URL) --broadcast --private-key $(ANVIL_DEFAULT_PRIVATE_KEY)

# Deploy to Sepolia Testnet
deploy-sepolia:
	forge script $(DEPLOY_SCRIPT) --rpc-url $(SEPOLIA_RPC_URL) --broadcast --private-key $(SEPOLIA_PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY)

