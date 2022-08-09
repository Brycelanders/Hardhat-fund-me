const { getNamedAccounts, ethers, network } = require("hardhat")
const { assert } = require("chai")
const { developmentChains } = require("../../helper-hardhat-config")

// assume this is on a test net, last step before deploying to mainnet

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", async function() {
          let fundMe
          let deployer
          const sendVAlue = ethers.utils.parseEther("1")

          beforeEach(async function() {
              deployer = await getNamedAccounts().deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })

          it("allows people to fund and withdraw", async function() {
              await fundMe.fund({ value: sendVAlue })
              await fundMe.withdraw()
              const endingBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )
              assert.equal(endingBalance.toString(), "0")
          })
      })
