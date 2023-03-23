import { deployments, getNamedAccounts, ethers } from "hardhat";

async function main() {
  const Proxy = await deployments.get("ERC1967Proxy");
  const Entrypoint = await deployments.get("Entrypoint");
  const EIP2929Wrapper = await deployments.get("EIP2929Wrapper");

  const { sender } = await hre.getNamedAccounts();
  const me = await hre.ethers.getSigner(sender);
  console.log(`sending tx with ${me.address}`);

  const iface = new ethers.utils.Interface(Entrypoint.abi);
  const arg = iface.encodeFunctionData("doTransfer(address)", [Proxy.address]);

  const tx = await me.sendTransaction({
    to: EIP2929Wrapper.address,
    data: arg,
    gasLimit: 1e7,
    gasPrice: 50e9,
  });
  await tx.wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
