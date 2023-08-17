import { task, types } from "hardhat/config";
import { HYPERLANE } from "../constants/deployments";

task("TASK_DEPLOY_HYPERLANE_ADAPTER", "Deploy hyperlane adapter contract")
  .addParam<boolean>("verify", "Verify hyperlane adapter contract", false, types.boolean)
  .setAction(
    async (taskArgs, hre): Promise<string> => {
      const HyperlaneAdapter = await hre.ethers.getContractFactory("HyperlaneAdapter");
      const igp = HYPERLANE["testnet"].igp;
      const mailbox = HYPERLANE["testnet"].mailbox;
      console.log("Deploying HyperlaneAdapter contract. This may take a few minutes..")
      const adapter = await HyperlaneAdapter.deploy(mailbox, igp, { gasLimit: 30000000 });
      await adapter.deployed();
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
