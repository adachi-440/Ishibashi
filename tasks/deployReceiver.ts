import { task, types } from "hardhat/config";

task("TASK_DEPLOY_RECEIVER", "Deploy receiver contract")
  .addParam<boolean>("verify", "Verify router contract", false, types.boolean)
  .setAction(
    async (taskArgs, hre): Promise<string> => {
      const Receiver = await hre.ethers.getContractFactory("MockReceiver");

      console.log("Deploying Receiver...");
      const receiver = await Receiver.deploy({ gasLimit: 10000000 });
      await receiver.deployed();
      console.log("Receiver deployed to:", receiver.address);
      if (taskArgs.verify) {
        await new Promise(f => setTimeout(f, 10000))

        await hre.run("TASK_VERIFY", {
          address: receiver.address
        });
      }
      return receiver.address;
    }
  );
