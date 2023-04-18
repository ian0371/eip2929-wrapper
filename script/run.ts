async function main() {
  const { deployments, getNamedAccounts } = hre;

  const Entrypoint = await deployments.get("Entrypoint");
  const EIP2929Wrapper = await deployments.get("EIP2929Wrapper");

  const { sender } = await getNamedAccounts();
  const me = await hre.ethers.getSigner(sender);
  console.log(`sending tx with ${me.address}`);

  const iface = new hre.ethers.utils.Interface(Entrypoint.abi);
  const tx = await me.sendTransaction({
    to: EIP2929Wrapper.address,
    data: iface.encodeFunctionData("doSomethingWithTransfer()"),
    gasLimit: 1e7,
    gasPrice: 50e9,
    value: 10,
  });
  await tx.wait();
  console.log(`txhash: ${tx.hash}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
