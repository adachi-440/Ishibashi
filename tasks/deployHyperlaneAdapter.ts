import { task, types } from "hardhat/config";
import { HYPERLANE_MAILBOX } from "../constants/deployments";

task("TASK_DEPLOY_HYPERLANE_ADAPTER", "Deploy hyperlane adapter contract")
  .addParam<string>("router", "router contract address", "", types.string)
  .addParam<boolean>("verify", "Verify hyperlane adapter contract", false, types.boolean)
  .setAction(
    async (taskArgs, hre): Promise<string> => {
      const HyperlaneAdapter = await hre.ethers.getContractFactory("HyperlaneAdapter");
      const router = taskArgs.router;

      console.log("Deploying HyperlaneAdapter contract. This may take a few minutes..")
      const adapter = await HyperlaneAdapter.deploy();
      await adapter.deployed();
      let tx = await adapter.init(router, HYPERLANE_MAILBOX.dstChainIds, HYPERLANE_MAILBOX.mailboxes);
      await tx.wait();
      console.log("HyperlaneAdapter deployed to:", adapter.address);
      if (taskArgs.verify) {
        await new Promise(f => setTimeout(f, 10000))

        await hre.run("TASK_VERIFY", {
          address: adapter.address
        });
      }
      return adapter.address;
    }
  );
