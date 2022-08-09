// when we want to test locally we need to use a mock due to hardcoded addresses being different across chains

const { network } = require("hardhat")
const {
    developmentChains,
    decimals,
    INITIAL_ANSWER
} = require("../helper-hardhat-config")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // function looking for the network name - if its dev server it will deploy the mocks contract
    if (developmentChains.includes(network.name)) {
        log("Local network detected, deploying mocks...")
        await deploy("MockV3Aggregator", {
            contract: "MockV3Aggregator",
            from: deployer,
            log: true,
            args: [decimals, INITIAL_ANSWER]
        })
        log("Mocks Deployed!")
        log("----------------------------------------------")
    }
}

module.exports.tags = ["all", "mocks"]
