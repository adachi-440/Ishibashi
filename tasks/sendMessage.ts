import { task, types } from "hardhat/config";
import ora from "ora";
import { ethers } from "hardhat";

task("TASK_SEND_MESSAGE", "Send message using router")
  .addParam<string>("router", "router contract address", "", types.string)
  .addParam<number>("chainid", "destination chain id", 0, types.int)
  .addParam<string>("recipient", "recipient address", "", types.string)
  .addParam<string>("message", "message", "", types.string)
  .addVariadicPositionalParam("adapters")
  .setAction(
    async (taskArgs, hre): Promise<null> => {
      const routerAddress = taskArgs.router,
        chainid = taskArgs.chainid,
        recipient = taskArgs.recipient,
        message = taskArgs.message,
        adapters = taskArgs.adapters;

      const router = await hre.ethers.getContractAt("Router", routerAddress);
      const messageBytes = ethers.utils.toUtf8Bytes(message);

      try {
        const spinner = ora(
          "Sending message. This may take a few minutes.."
        ).start();
        const tx = await router.sendMessage(chainid, recipient, messageBytes, adapters);
        await tx.wait();
        spinner.succeed(`Sent transaction: ${tx.hash}`);

      } catch (e: any) {
        if (e.error.message.includes("The chainId + address is already trusted")) {
          console.log("*source already set*")
        } else {
          console.log(`❌ [${hre.network.name}] Fail to send message`)
        }
        console.log(e)
      }
      return null;
    }
  );
