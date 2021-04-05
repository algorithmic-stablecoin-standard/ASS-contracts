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

import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Market.sol";
import "./Regulator.sol";
import "../oracle/Pool.sol";
import "./Govern.sol";
import "./NinetyDayAssSale.sol";
import "../Constants.sol";

import "../token/IDollar.sol";
import "../oracle/IOracle.sol";

contract Implementation is PoolState, Pool, Market, Regulator, Govern, NinetyDayAssSale {
    using SafeMath for uint256;

    event Advance(uint256 indexed epoch, uint256 block, uint256 timestamp);
    event Incentivization(address indexed account, uint256 amount);

    function initialize() public initializer {
        // // Reward committer
        // incentivize(msg.sender, Constants.getAdvanceIncentive());

        _state.provider.dollar = IDollar(address(0));
        _state.provider.oracle = IOracle(address(0));
        _state.provider.dev = msg.sender;

        require(_state.provider.dollar != IDollar(0), "Implementation: dollar != 0");
        require(_state.provider.oracle != IOracle(0), "Implementation: oracle != 0");

        // add end sale
        endSale = block.timestamp + 90 days;
    }

    function advance() external {
        incentivize(msg.sender, Constants.getAdvanceIncentive());

        Pool.step();
        Regulator.step();
        Market.step();

        emit Advance(epoch(), block.number, block.timestamp);
    }

    function incentivize(address account, uint256 amount) private {
        mintToAccount(account, amount);
        emit Incentivization(account, amount);
    }
}
