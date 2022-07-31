// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    uint public reserve0;
    uint public reserve1;

    uint public totalsupply;
    mapping(address => uint) public balanceOf;

    constructor (address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = UERC20(_token1);
    }

    function _mint (address _to, uint _amount) private {
        balanceOf[_to] += _amount;
        totalsupply += _amount; 
    }

      function _burn (address _from, uint _amount) private {
        balanceOf[_from] -= _amount;
        totalsupply -= _amount; 
    }

    function _update (uint _reserve0, uint _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function swap (address _tokenIn, uint _amount) external returns (uint amountOut) {
        require (_tokenIn == address(token0) || _tokenIn == address(token1), "invalide token");
        require(_amountIn > 0, "amount In is zero");

        //pull in token in
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint reserveIn, uint reserveOut) = isToken0 
        ? (token0, token1, reserve0, reserve1)
        : (token1, token0, reserve1, reserve0);

        tokenIn.transferFrom(_msgSender(), address(this), _amountIn);

        //calculate token out include fees , fee 0.3%
        // ydx / (x + dx) = dy
        uint amountInWithFee = (_amountIn * 997) / 1000;
        amountOut = (reserveOut * amountInWithFee) / (reserveIn + amountInWithFee);

        //transfer token out to msg.sender
        tokenOut.transfer(_msgSender(), amountOut);
        // update the reserves 
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );

    }

    function addLiquidity (uint _amount0, uint _amount1) external returns (uint shares) {
        // pull in token0 and token1
        token0.transferFrom(_msgSender(), address(this), _amount0);
        token1.transferFrom(_msgSender(), address(this), _amount1);

        // dy / dx = y / x
        if (reserve0 > 0 || reserve1 > 0) {
            require(reserve0 * _amount1 == reserve1 * _amount0, "dy / dx != y / x");
        }

        // mint shares
        // f(x, y) = value of liquidity = sqrt(xy)
        // s = dx / x * T = dy / y * T
        if (totalsupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalsupply) / reserve0,
                (_amount1 * totalsupply) / reserve1

            );
        }
        require(shares > 0, "shares = 0");
        _mint(_msgSender(), shares);
        // update reserves
        _update(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function removeLiquidity (uint _shares) external returns (uint amount0, uint amount1) {
        // calculate amount0 and amount1 to withdraw
        // dx = s / T * x
        // dy = s / T * y
        uint bal0 = token0.balanceOf(address(this));
        uint bal1 = token1.balanceOf(address(this));

        amount0 = (_shares * bal0) / totalsupply;
        amount01= (_shares * bal1) / totalsupply;
        require(amount0 > 0 && amount1 > 0, "amount0 or amount1 = 0");

        // burn shares
        _burn(_msgSender(), _shares);

        // update reserves
        _update(bal0 - amount0, bal1 - amount1);

        // transfer tokens to msg.sender
        token0.transfer(_msgSender(), amount0);
        token1.transfer(_msgSender(), amount1);
    }

    function _sqrt(uint y) private pure returns (uint z) {
        if (y > 3) {
            z = y; 
            uint x = y / z + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        }else if (y != 0) {
            z = 1;
        }
    }

    function _min (uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }
}