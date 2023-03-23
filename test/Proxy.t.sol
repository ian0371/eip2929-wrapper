// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract EIP2929ProxyTest is Test {
    address public eip2929proxy;

    function setUp() public {
        eip2929proxy = deployCode("EIP2929Proxy.sol:EIP2929Proxy");
    }
}
