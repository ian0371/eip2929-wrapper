pragma solidity ^0.8.18;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Entrypoint {
    function doTransfer(address payable x) public payable {
        x.transfer(msg.value);
    }

    function doCall(address payable x) public payable {
        x.call{value: msg.value}("");
    }
}

contract Receiver {
    uint256 public number;

    receive() external payable {
        number++;
    }
}
