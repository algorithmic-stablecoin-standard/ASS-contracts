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

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../oracle/PoolGetters.sol";

contract NinetyDayAssSale is PoolGetters {
    using SafeMath for uint256;
    event Minted1t1(address indexed account, uint256 amount);

    uint256 public endSale;
    uint256 public amountMinted;

    function mint1t1Ass(uint256 amount) external {
        require(block.timestamp < endSale, "90 day sale has ended");

        IERC20(Constants.getUsdcAddress()).transferFrom(msg.sender, address(this), amount);

        dollar().mint(msg.sender, amount);

        emit Minted1t1(msg.sender, amount);
    }
}
