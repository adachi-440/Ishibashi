import { task, types } from "hardhat/config";
import { HYPERLANE_MAILBOX } from "../constants/deployments";
import ora from "ora";

task("TASK_DEPLOY_ROUTER", "Deploy router contract")
  .addParam<boolean>("verify", "Verify router contract", false, types.boolean)
  .setAction(
    async (taskArgs, hre): Promise<string> => {
      const Router = await hre.ethers.getContractFactory("Router");

      const spinner = ora(
        "Deploying router contract. This may take a few minutes.."
      ).start();
      const router = await Router.deploy(1);
      await router.deployed();
      spinner.succeed(`Router deployed to: ${router.address}`);
      if (taskArgs.verify) {
        await new Promise(f => setTimeout(f, 10000))

        await hre.run("TASK_VERIFY", {
          address: router.address
        });
      }
      return router.address;
    }
  );
