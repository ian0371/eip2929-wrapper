import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const func: DeployFunction = async (hre: HardhatRuntimeEnvironment) => {
  const { deployments, getNamedAccounts } = hre;

  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const Proxy = await deployments.get("ERC1967Proxy");
  const Receiver = await deployments.get("Receiver");
  const iface = new hre.ethers.utils.Interface(Receiver.abi);

  await deploy("EIP2929Wrapper", {
    from: deployer,
    gasLimit: 4000000,
    args: [Proxy.address, Receiver.address, iface.encodeFunctionData("number()")],
    log: true,
  });
};

func.tags = ["Wrapper"];
func.dependencies = ["Proxy", "Receiver"];
export default func;
