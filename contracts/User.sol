pragma solidity ^0.8.18;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Entrypoint {
    address payable public receiverProxy;

    constructor(address payable _receiverProxy) {
        receiverProxy = _receiverProxy;
    }

    function doSomethingWithTransfer() public payable {
        receiverProxy.transfer(msg.value);
    }
}

contract Receiver {
    uint256 public number;

    fallback() external payable {}

    receive() external payable {}

    function withdraw() external payable {
        address(msg.sender).call{value: address(this).balance}("");
    }
}
