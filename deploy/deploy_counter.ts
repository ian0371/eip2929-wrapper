import { deployments } from "hardhat";
import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("Receiver", {
    from: deployer,
    gasLimit: 4000000,
    args: [],
    log: true,
  });
};

func.tags = ["Receiver"];
export default func;
