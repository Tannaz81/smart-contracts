// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract AbiDecode {

    struct Mystruct {
        string name;
        uint[2] nums;
    }

    function encode (
    uint x,
    address addr,
    uint[] calldata arr,
    Mystruct calldata mystruct) external pure returns (bytes memory) {
        return abi.encode(x, addr, arr, mystruct);
    }

    function decode (bytes calldata data) external pure returns (
        uint x,
        address addr,
        uint[] memory arr,
        Mystruct memory mystruct) {
        (x, addr, arr, mystruct) = abi.decode(data, (uint, address, uint[], Mystruct));
        }
    
}