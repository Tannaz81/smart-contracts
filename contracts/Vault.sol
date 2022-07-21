// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Vault {
    IERC20 public immutable token;

    uint public totalsupply;
    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function _mint(address _to, uint _amount) private {
       totalsupply += _amount;
       balanceOf[_to] += _amount;
    }

    
    function _burn (address _from, uint _amount) private {
       totalsupply -= _amount;
       balanceOf[_from] -= _amount;
    }

    function deposit(uint _amount) external {
        /* 
        a = amount
        B = balance of token before deposit
        T = total supply
        s = shares to mint 
        (T + s) / T = (a = B) / B
        s = aT / B
        */ 
        uint shares;
        if (totalsupply == 0) {
            shares = amount;
        } else {
            shares = (_amount * totalsupply) / token.balanceOf(address(this));
        }

        _mint(_msgSender(), shares);
        token.transferFrom(_msgSender(), address(this), _amount);
    }

    function withdraw(uint _shares) external {
        /*
        a = amount
        B = balance of token before withdraw
        T = total supply
        s = shares to burn
        (T - s) / T = (B - a) / B
        a = sB / T
        */
        uint amount = (_shares * token.balanceOf(address(this))) / totalsupply;
        _burn(_msgSender(), _shares);
        token.transfer(_msgSender(), amount);


    }

}