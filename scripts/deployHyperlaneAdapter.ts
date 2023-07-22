import { ethers } from "hardhat";
import { HYPERLANE_MAILBOX } from "../constants/deployments";

async function main() {

  const HyperlaneAdapter = await ethers.getContractFactory("HyperlaneAdapter");
  const hyperlaneAdapter = await HyperlaneAdapter.deploy(HYPERLANE_MAILBOX);

  await hyperlaneAdapter.deployed();

  console.log(`HyperlaneAdapter deployed to ${hyperlaneAdapter.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
