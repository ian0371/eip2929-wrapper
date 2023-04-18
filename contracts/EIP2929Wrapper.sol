pragma solidity ^0.8.0;

contract EIP2929Wrapper {
    // this wrapper will call `prefetch` address with `prefetchCallArg` before
    // calling `to` address with `msg.calldata`
    // Note that calling prefetch with prefetchCallArgs MUST NOT revert.
    address public prefetch;
    address public to;
    bytes public prefetchCallArgs;

    constructor(address _prefetch, address _to, bytes memory _prefetchCallArgs) {
        prefetch = _prefetch; // ERC1967Proxy
        to = _to; // Entrypoint
        prefetchCallArgs = _prefetchCallArgs;
    }

    fallback() external payable {
        _preloadAndCall();
    }

    receive() external payable {
        _preloadAndCall();
    }

    function _preloadAndCall() private {
        // NOTE: this MUST NOT revert
        prefetch.call(prefetchCallArgs);

        address _to = to;

        assembly {
            // CALL
            calldatacopy(0, 0, calldatasize())

            let result := call(gas(), _to, callvalue(), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
