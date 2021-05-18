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
import "../token/IDollar.sol";
import "./IOracle.sol";
import "./IUSDC.sol";
import "../external/Decimal.sol";

contract PoolAccount {
    enum Status { Frozen, Fluid, Locked }

    struct State {
        uint256 staged;
        uint256 claimable;
        uint256 bonded;
        uint256 phantom;
        uint256 fluidUntil;
        mapping(uint256 => uint256) coupons;
        mapping(address => uint256) couponAllowances;
        uint256 lockedUntil;
    }
}

contract Epoch {
    struct Global {
        uint256 start;
        uint256 period;
        uint256 current;
    }

    struct State {
        uint256 bonded;
    }
}

contract Candidate {
    enum Vote { UNDECIDED, APPROVE, REJECT }

    struct State {
        uint256 start;
        uint256 period;
        uint256 approve;
        uint256 reject;
        mapping(address => Vote) votes;
        bool initialized;
    }
}

contract Era {
    enum Status { EXPANSION, CONTRACTION }

    struct State {
        Status status;
        uint256 start;
    }
}

contract PoolStorage {
    struct Provider {
        address dev;
        IDollar dollar;
        IOracle oracle;
        IERC20 univ2;
    }

    struct Balance {
        uint256 staged;
        uint256 claimable;
        uint256 bonded;
        uint256 phantom;
        uint256 redeemable;
        uint256 debt;
        uint256 coupons;
    }

    struct State {
        Balance balance;
        bool paused;
        mapping(address => PoolAccount.State) accounts;
        Provider provider;
        mapping(uint256 => Epoch.State) epochs;
        mapping(address => Candidate.State) candidates;
        mapping(address => mapping(uint256 => uint256)) couponUnderlyingByAccount;
        Epoch.Global epoch;
        Era.State era;
        uint256 couponUnderlying;
        address[] candidateHistory;
    }
}

contract PoolState {
    PoolStorage.State _state;
}
