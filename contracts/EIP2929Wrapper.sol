pragma solidity ^0.8.0;

/**
 * @title EIP2929Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract EIP2929Wrapper {
    /**
     * @dev Fallback function allowing to perform a delegatecall to the given implementation.
     * This function will return whatever the implementation call returns
     */

    fallback() external payable {
        address prefetch = 0x6a9880894a09873B908933F1528d368ffbc465Ef;
        address to = 0x86eaCD34aeae879543C522d503Fa3204fdA6fF34;

        // PRE-SLOAD by calling prefetch contract
        // NOTE: this MUST NOT revert
        prefetch.call{value: msg.value}("");

        assembly {
            // CALL
            calldatacopy(0, 0, calldatasize())

            let result := call(gas(), to, callvalue(), 0, calldatasize(), 0, 0)

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
