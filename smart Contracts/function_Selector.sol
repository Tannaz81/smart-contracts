// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract FunctionSelector {
    function getSelector (string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}
  
  
contract Receiver {
    event log(bytes data);

    function transfer (address _to, uint _amount) external {
       emit log(msg.data);
        //0xa9059cbb
        //0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc
        //4000000000000000000000000000000000000000000000000000000000000000b
    }

  }