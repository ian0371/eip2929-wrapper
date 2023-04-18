// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "contracts/EIP2929Wrapper.sol";
import "contracts/User.sol";

contract EIP2929WrapperScript is Script {
    EIP2929Wrapper public wrapper;
    Entrypoint public ep;
    ERC1967Proxy public proxy;
    Receiver public r;
    uint256 public sender;

    function setUp() public {
        sender = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.deal(vm.addr(sender), 1e18 ether);
        vm.startBroadcast(sender);

        r = new Receiver();
        proxy = new ERC1967Proxy(address(r), "");
        ep = new Entrypoint(payable(address(proxy)));
        wrapper = new EIP2929Wrapper(address(proxy), address(ep), abi.encodeWithSignature("number()"));

        console.log("Receiver", address(r));
        console.log("Proxy", address(proxy));
        console.log("Entrypoint", address(ep));
        console.log("EIP2929Wrapper", address(wrapper));

        vm.stopBroadcast();
    }

    function run() public {
        bytes memory arg = abi.encodeWithSignature("doSomethingWithTransfer()");

        vm.startBroadcast(sender);

        (bool status, ) = address(wrapper).call{value: 0.01 ether}(arg);

        vm.stopBroadcast();

        require(status, "call reverted");
        console.log("balance of Proxy:", address(proxy).balance);
    }
}
