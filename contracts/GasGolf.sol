// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// if we deploy this contract , gas would be 50908 
contract GasGolf {
    uint public total;

    function sumIfEvenAndLessThan99 (uint[] memory nums) external {
        for (uint i = 0; i < nums.length; i += 1) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }
}

// so i show u some gas saving technique

// 1: use calldata instead of memory , 49163 gas
// 2: load state variables to memory , 48952 gas
// 3: short circuit , 48634 gas
// 4: loop increments , 48226 gas
// 5: cache array length , 48191 gas
// 6: load array elements to memory , 48029 gas


    function sumIfEvenAndLessThan99 (uint[] calldata nums) external {
        // for the input of this function u can use [1, 2, 3, 4, 5, 100]
        uint _total = total;
        uint len = nums.length;

        for (uint i = 0; i < len; ++i) {
           uint num = nums[i];
            if (num % 2 == 0 && num < 99) {
                _total += nums;
            }
        }
    }

   
// now if we deploy this , we save like 2879 gas