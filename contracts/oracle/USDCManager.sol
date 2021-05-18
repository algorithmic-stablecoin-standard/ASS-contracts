/*
    Copyright 2020 Algorithmic Stablecoin Posse <ryorich@protonmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity ^0.5.17;
pragma experimental ABIEncoderV2;

import "./IUniswapV2Router.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../Constants.sol";

// @dev This is a standalone contract. It is responsible for swapping USDC to ASS for the stabbot
contract USDCManager {
    using SafeMath for uint256;
    address public devAddr;
    address public dollarAddr;
    address[] public path = [Constants.getUsdcAddress()];

    constructor() public {
        uint256 MAX_INT = 2**256 - 1;
        devAddr = msg.sender;

        IERC20(Constants.getUsdcAddress()).approve(Constants.getPancakeSwapRouterAddress(), MAX_INT);
    }

    function swapUsdcForAss(uint256 amount) external onlyBot {
        require(dollarAddr != address(0), "dollarAddr address is empty");

        uint256 usdcBalance = IERC20(Constants.getUsdcAddress()).balanceOf(address(this));
        uint256 onePercentOfUSDC = usdcBalance.mul(1).div(100);
        require(amount <= onePercentOfUSDC, "cannot take more than 1%");

        uint256[] memory amountsIn =
            IUniswapV2Router(Constants.getPancakeSwapRouterAddress()).getAmountsIn(amount, path);

        IUniswapV2Router(Constants.getPancakeSwapRouterAddress()).swapTokensForExactTokens(
            amount,
            amountsIn[0],
            path,
            Constants.getStabilizerBotAddress(),
            block.timestamp
        );
    }

    function emergencyWithdraw(address token, uint256 value) external onlyDev {
        IERC20(token).transfer(devAddr, value);
    }

    function addDollarAddr(address _dollarAddr) external onlyDev {
        require(dollarAddr == address(0), "Can only add dollar address once");

        dollarAddr = _dollarAddr;
        path.push(dollarAddr);
    }

    function setDev(address newDev) external onlyDev {
        devAddr = newDev;
    }

    modifier onlyDev() {
        require(msg.sender == devAddr, "Not dev");

        _;
    }

    modifier onlyBot() {
        require(msg.sender == Constants.getStabilizerBotAddress(), "Not bot");

        _;
    }
}
