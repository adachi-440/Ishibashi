import { ethers, network } from "hardhat";
import { HYPERLANE_ADAPTER, HYPERLANE_MAILBOX, ROUTER } from "../constants/deployments";

async function main() {
  const router = ROUTER[network.name as keyof typeof ROUTER]

  // set router in hyperlane adapter
  const hyperlaneAdapter = await ethers.getContractAt("HyperlaneAdapter", HYPERLANE_ADAPTER[network.name as keyof typeof HYPERLANE_ADAPTER])

  console.log(`Setting router to ${router}`);
  let tx = await hyperlaneAdapter.setRouter(router);
  await tx.wait();

  console.log(`Completed setting router to ${router}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
