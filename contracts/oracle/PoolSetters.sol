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
import "./PoolState.sol";
import "./PoolGetters.sol";

contract PoolSetters is PoolState, PoolGetters {
    using SafeMath for uint256;

    /**
     * ERC20 Interface
     */

    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _state.accounts[sender].bonded = _state.accounts[sender].bonded.sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _state.accounts[recipient].bonded = _state.accounts[recipient].bonded.add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }

    /**
     * Global
     */

    function pause() internal {
        _state.paused = true;
    }

    function incrementTotalDebt(uint256 amount) internal {
        _state.balance.debt = _state.balance.debt.add(amount);
    }

    function decrementTotalDebt(uint256 amount, string memory reason) internal {
        _state.balance.debt = _state.balance.debt.sub(amount, reason);
    }

    function incrementTotalRedeemable(uint256 amount) internal {
        _state.balance.redeemable = _state.balance.redeemable.add(amount);
    }

    function decrementTotalRedeemable(uint256 amount, string memory reason) internal {
        _state.balance.redeemable = _state.balance.redeemable.sub(amount, reason);
    }

    function updateEra(Era.Status status) internal {
        _state.era.status = status;
        _state.era.start = epoch();
    }

    /**
     * Account
     */

    function incrementBalanceOfBonded(address account, uint256 amount) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.add(amount);
        _state.balance.bonded = _state.balance.bonded.add(amount);
    }

    function decrementBalanceOfBonded(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].bonded = _state.accounts[account].bonded.sub(amount, reason);
        _state.balance.bonded = _state.balance.bonded.sub(amount, reason);
    }

    function incrementBalanceOfStaged(address account, uint256 amount) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.add(amount);
        _state.balance.staged = _state.balance.staged.add(amount);
    }

    function decrementBalanceOfStaged(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].staged = _state.accounts[account].staged.sub(amount, reason);
        _state.balance.staged = _state.balance.staged.sub(amount, reason);
    }

    function incrementBalanceOfClaimable(address account, uint256 amount) internal {
        _state.accounts[account].claimable = _state.accounts[account].claimable.add(amount);
        _state.balance.claimable = _state.balance.claimable.add(amount);
    }

    function decrementBalanceOfClaimable(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].claimable = _state.accounts[account].claimable.sub(amount, reason);
        _state.balance.claimable = _state.balance.claimable.sub(amount, reason);
    }

    function incrementBalanceOfPhantom(address account, uint256 amount) internal {
        _state.accounts[account].phantom = _state.accounts[account].phantom.add(amount);
        _state.balance.phantom = _state.balance.phantom.add(amount);
    }

    function decrementBalanceOfPhantom(
        address account,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].phantom = _state.accounts[account].phantom.sub(amount, reason);
        _state.balance.phantom = _state.balance.phantom.sub(amount, reason);
    }

    function unfreeze(address account) internal {
        _state.accounts[account].fluidUntil = epoch().add(Constants.getPoolExitLockupEpochs());
    }

    function incrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].add(amount);
        _state.balance.coupons = _state.balance.coupons.add(amount);
    }

    function incrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount
    ) internal {
        _state.couponUnderlyingByAccount[account][epoch] = _state.couponUnderlyingByAccount[account][epoch].add(amount);
        _state.couponUnderlying = _state.couponUnderlying.add(amount);
    }

    function decrementBalanceOfCoupons(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[account].coupons[epoch] = _state.accounts[account].coupons[epoch].sub(amount, reason);
        _state.balance.coupons = _state.balance.coupons.sub(amount, reason);
    }

    function decrementBalanceOfCouponUnderlying(
        address account,
        uint256 epoch,
        uint256 amount,
        string memory reason
    ) internal {
        _state.couponUnderlyingByAccount[account][epoch] = _state.couponUnderlyingByAccount[account][epoch].sub(
            amount,
            reason
        );
        _state.couponUnderlying = _state.couponUnderlying.sub(amount, reason);
    }

    function updateAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = amount;
    }

    function decrementAllowanceCoupons(
        address owner,
        address spender,
        uint256 amount,
        string memory reason
    ) internal {
        _state.accounts[owner].couponAllowances[spender] = _state.accounts[owner].couponAllowances[spender].sub(
            amount,
            reason
        );
    }

    /**
     * Epoch
     */

    function incrementEpoch() internal {
        _state.epoch.current = _state.epoch.current.add(1);
    }

    function snapshotTotalBonded() internal {
        _state.epochs[epoch()].bonded = totalBonded();
    }

    /**
     * Governance
     */

    function createCandidate(address candidate, uint256 period) internal {
        _state.candidates[candidate].start = epoch();
        _state.candidates[candidate].period = period;
        _state.candidateHistory.push(candidate);
    }

    function recordVote(
        address account,
        address candidate,
        Candidate.Vote vote
    ) internal {
        _state.candidates[candidate].votes[account] = vote;
    }

    function incrementApproveFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.add(amount);
    }

    function decrementApproveFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
        _state.candidates[candidate].approve = _state.candidates[candidate].approve.sub(amount, reason);
    }

    function incrementRejectFor(address candidate, uint256 amount) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.add(amount);
    }

    function decrementRejectFor(
        address candidate,
        uint256 amount,
        string memory reason
    ) internal {
        _state.candidates[candidate].reject = _state.candidates[candidate].reject.sub(amount, reason);
    }

    function placeLock(address account, address candidate) internal {
        uint256 currentLock = _state.accounts[account].lockedUntil;
        uint256 newLock = startFor(candidate).add(periodFor(candidate));
        if (newLock > currentLock) {
            _state.accounts[account].lockedUntil = newLock;
        }
    }

    function initialized(address candidate) internal {
        _state.candidates[candidate].initialized = true;
    }
}
