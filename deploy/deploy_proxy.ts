import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const counter = await deployments.get("Counter");

  await deploy("ERC1967Proxy", {
    from: deployer,
    gasLimit: 4000000,
    args: [counter.address, "0x"],
    log: true,
  });
};

func.tags = ["Proxy"];
func.dependencies = ["Counter"];
export default func;
