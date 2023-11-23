// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

contract UniswapV3Twap {
    address public immutable token0;
    address public immutable token1;
    address public immutable pool;

    constructor(address _factory, address _token0, address _token1, uint24 _fee) {
        token0 = _token0;
        token1 = _token1;

        address _pool = IUniswapV3Factory(_factory).getPool(_token0, _token1, _fee);
        require(_pool != address(0), "Pool does not exist.");
        pool = _pool;
    }

    function estimateAmountOut(
        address _tokenIn,
        uint128 _amountIn,
        uint32 _secondsAgo
    ) external view returns (uint256 amountOut) {
        require(_tokenIn == token0 || _tokenIn == token1, "Invalid token.");
        address tokenOut = _tokenIn == token0 ? token1 : token0;

        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = _secondsAgo;
        secondsAgos[1] = 0;

        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        int24 tick = int24(tickCumulativesDelta / _secondsAgo);
        // Always round to negative infinity
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % _secondsAgo != 0)) {
            tick--;
        }
        amountOut = OracleLibrary.getQuoteAtTick(tick, _amountIn, _tokenIn, tokenOut);
    }
}
