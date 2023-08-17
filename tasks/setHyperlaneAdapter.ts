import { task, types } from "hardhat/config";

task("TASK_SET_HYPERLANE_ADAPTER", "Send message using router")
  .addParam<string>("router", "router contract address", "", types.string)
  .addParam<string>("hyperlane", "adapter contract address", "", types.string)
  .addParam<number>("chainid", "adapter contract address", 0, types.int)
  .addParam<string>("adapter", "adapter contract address", "", types.string)
  .setAction(
    async (taskArgs, hre): Promise<null> => {
      const hyperlane = await hre.ethers.getContractAt("HyperlaneAdapter", taskArgs.hyperlane);
      const dstChainId = taskArgs.chainid,
        dstAdapter = taskArgs.adapter;

      try {
        const tx = await hyperlane.init(taskArgs.router, [dstChainId], [dstAdapter]);
        await tx.wait();
        console.log(`✅ [${hre.network.name}] tx: ${tx.hash}`);
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
