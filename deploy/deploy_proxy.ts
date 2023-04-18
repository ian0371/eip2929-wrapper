import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const Receiver = await deployments.get("Receiver");

  await deploy("ERC1967Proxy", {
    from: deployer,
    gasLimit: 4000000,
    args: [Receiver.address, "0x"],
    log: true,
  });
};

func.tags = ["Proxy"];
func.dependencies = ["Receiver"];
export default func;
