// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "contracts/User.sol";

contract EIP2929WrapperScript is Script {
    address public wrapper;
    Entrypoint public ep;
    ERC1967Proxy public proxy;
    Receiver public r;
    uint256 public sender;

    function setUp() public {
        sender = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
        vm.deal(vm.addr(sender), 1e18 ether);
        vm.startBroadcast(sender);

        if (block.chainid == 1001) {
            r = Receiver(payable(0x639A860F5271F884B53157CcFc60993Db662f13e));
            proxy = ERC1967Proxy(payable(0x6a9880894a09873B908933F1528d368ffbc465Ef));
            ep = Entrypoint(0xDCc67e78aBbe02b5D221630D34992C7E81d2C6a5);
            wrapper = 0x2fb621Ca546402BFF7d65aAE137dD5132A4C7672;
        } else {
            r = new Receiver();
            proxy = new ERC1967Proxy(address(r), "");
            ep = new Entrypoint();
            wrapper = deployCode("EIP2929Wrapper.sol:EIP2929Wrapper");
        }

        console.log("Receiver", address(r));
        console.log("proxy", address(proxy));
        console.log("entrypoint", address(ep));
        console.log("wrapper", wrapper);

        vm.stopBroadcast();
    }

    function run() public {
        runDoTransferWithWrapper();
        // runDoTransferWithoutWrapper();
    }

    // will succeed
    function runDoTransferWithWrapper() public {
        bytes memory arg;
        bytes memory ret;
        bool status;

        // 1st argument: address to preload
        // 2nd argument: address to call
        arg = abi.encode(address(proxy), address(ep));
        arg = bytes.concat(arg, abi.encodeWithSignature("doTransfer(address)", address(proxy)));

        vm.expectRevert();
        vm.startBroadcast(sender);

        (status, ret) = wrapper.call{value: 0.1 ether}(arg);

        vm.stopBroadcast();

        require(status, "call reverted");
        require(address(proxy).balance == 0.1 ether);
    }

    // will fail
    function runDoTransferWithoutWrapper() public {
        vm.startBroadcast(sender);

        try ep.doTransfer{value: 0.1 ether}(payable(address(proxy))) {
            revert("why not revert?");
        } catch (bytes memory reason) {
            console.log("reverted as expected");
            console.logBytes(reason);
        }

        vm.stopBroadcast();

        console.log(address(proxy).balance);
        // require(address(proxy).balance == 0 ether);
    }

    // will succeed
    function runDoCallWithoutWrapper() public {
        vm.startBroadcast(sender);

        ep.doCall{value: 0.1 ether}(payable(address(proxy)));

        vm.stopBroadcast();

        console.log(address(proxy).balance);
        require(address(proxy).balance == 0.1 ether);
    }

    function callNumber() public view returns (uint256) {
        bytes memory arg;
        arg = abi.encodeWithSignature("number()");
        (bool status, bytes memory ret) = address(proxy).staticcall(arg);
        require(status, "staticcall to proxy failed");
        return abi.decode(ret, (uint256));
    }
}
