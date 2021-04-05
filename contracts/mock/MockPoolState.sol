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

import "../oracle/PoolSetters.sol";

contract MockPoolState is PoolSetters {
    address internal _dollar;
    address private _dev;

    function set(address dollar, address dev) external {
        _dollar = dollar;
        _dev = dev;
    }

    function dollar() public view returns (IDollar) {
        return IDollar(_dollar);
    }

    function dev() public view returns (address) {
        return _dev;
    }

    /**
     * Global
     */

    function incrementTotalDebtE(uint256 amount) external {
        super.incrementTotalDebt(amount);
    }

    function decrementTotalDebtE(uint256 amount, string calldata reason) external {
        super.decrementTotalDebt(amount, reason);
    }

    function incrementTotalRedeemableE(uint256 amount) external {
        super.incrementTotalRedeemable(amount);
    }

    function decrementTotalRedeemableE(uint256 amount, string calldata reason) external {
        super.decrementTotalRedeemable(amount, reason);
    }

    function updateEraE(Era.Status status) external {
        super.updateEra(status);
    }

    /**
     * Epoch
     */

    function setEpochParamsE(uint256 start, uint256 period) external {
        _state.epoch.start = start;
        _state.epoch.period = period;
    }

    function incrementEpochE() external {
        super.incrementEpoch();
    }

    function snapshotTotalBondedE() external {
        super.snapshotTotalBonded();
    }

    /**
     * Governance
     */

    function createCandidateE(address candidate, uint256 period) external {
        super.createCandidate(candidate, period);
    }

    function recordVoteE(
        address account,
        address candidate,
        Candidate.Vote vote
    ) external {
        super.recordVote(account, candidate, vote);
    }

    function incrementApproveForE(address candidate, uint256 amount) external {
        super.incrementApproveFor(candidate, amount);
    }

    function decrementApproveForE(
        address candidate,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementApproveFor(candidate, amount, reason);
    }

    function incrementRejectForE(address candidate, uint256 amount) external {
        super.incrementRejectFor(candidate, amount);
    }

    function decrementRejectForE(
        address candidate,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementRejectFor(candidate, amount, reason);
    }

    function placeLockE(address account, address candidate) external {
        super.placeLock(account, candidate);
    }

    function initializedE(address candidate) external {
        super.initialized(candidate);
    }

    /**
     * Account
     *
     */

    function incrementBalanceOfCouponsE(
        address account,
        uint256 epoch,
        uint256 amount
    ) external {
        super.incrementBalanceOfCoupons(account, epoch, amount);
    }

    function incrementBalanceOfCouponUnderlyingE(
        address account,
        uint256 epoch,
        uint256 amount
    ) external {
        super.incrementBalanceOfCouponUnderlying(account, epoch, amount);
    }

    function decrementBalanceOfCouponsE(
        address account,
        uint256 epoch,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfCoupons(account, epoch, amount, reason);
    }

    function decrementBalanceOfCouponUnderlyingE(
        address account,
        uint256 epoch,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfCouponUnderlying(account, epoch, amount, reason);
    }

    function updateAllowanceCouponsE(
        address owner,
        address spender,
        uint256 amount
    ) external {
        super.updateAllowanceCoupons(owner, spender, amount);
    }

    function decrementAllowanceCouponsE(
        address owner,
        address spender,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementAllowanceCoupons(owner, spender, amount, reason);
    }

    function incrementBalanceOfBondedE(address account, uint256 amount) external {
        super.incrementBalanceOfBonded(account, amount);
    }

    function decrementBalanceOfBondedE(
        address account,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfBonded(account, amount, reason);
    }

    function incrementBalanceOfStagedE(address account, uint256 amount) external {
        super.incrementBalanceOfStaged(account, amount);
    }

    function decrementBalanceOfStagedE(
        address account,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfStaged(account, amount, reason);
    }

    function incrementBalanceOfClaimableE(address account, uint256 amount) external {
        super.incrementBalanceOfClaimable(account, amount);
    }

    function decrementBalanceOfClaimableE(
        address account,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfClaimable(account, amount, reason);
    }

    function incrementBalanceOfPhantomE(address account, uint256 amount) external {
        super.incrementBalanceOfPhantom(account, amount);
    }

    function decrementBalanceOfPhantomE(
        address account,
        uint256 amount,
        string calldata reason
    ) external {
        super.decrementBalanceOfPhantom(account, amount, reason);
    }

    function unfreezeE(address account) external {
        super.unfreeze(account);
    }
}
