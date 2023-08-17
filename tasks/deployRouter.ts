import { task, types } from "hardhat/config";

task("TASK_DEPLOY_ROUTER", "Deploy router contract")
  .addParam<boolean>("verify", "Verify router contract", false, types.boolean)
  .setAction(
    async (taskArgs, hre): Promise<string> => {
      const Router = await hre.ethers.getContractFactory("Router");

      console.log("Deploying Router...");
      const router = await Router.deploy({ gasLimit: 10000000 });
      await router.deployed();
      console.log("Router deployed to:", router.address);
      if (taskArgs.verify) {
        await new Promise(f => setTimeout(f, 10000))

        await hre.run("TASK_VERIFY", {
          address: router.address
        });
      }
      return router.address;
    }
  );
