import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const Proxy = await deployments.get("ERC1967Proxy");

  await deploy("Entrypoint", {
    from: deployer,
    gasLimit: 4000000,
    args: [Proxy.address],
    log: true,
  });
};

func.tags = ["Entrypoint"];
func.dependencies = ["Proxy"];
export default func;
