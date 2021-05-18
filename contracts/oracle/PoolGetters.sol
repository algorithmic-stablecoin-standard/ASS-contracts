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
import "../Constants.sol";

contract PoolGetters is PoolState {
    using SafeMath for uint256;

    using Decimal for Decimal.D256;

    bytes32 private constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * ERC20 Interface
     */

    mapping(address => mapping(address => uint256)) internal _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() public view returns (string memory) {
        return "Algorithmic Stablecoin Standard LP Shares";
    }

    function symbol() public view returns (string memory) {
        return "ASSLPS";
    }

    function decimals() public view returns (uint8) {
        return 18;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _state.accounts[account].bonded;
    }

    function totalSupply() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * Global
     */

    function usdc() public view returns (address) {
        return Constants.getUsdcAddress();
    }

    function dev() public view returns (address) {
        return _state.provider.dev;
    }

    function oracle() public view returns (IOracle) {
        return _state.provider.oracle;
    }

    function dollar() public view returns (IDollar) {
        return _state.provider.dollar;
    }

    function univ2() public view returns (IERC20) {
        return _state.provider.univ2;
    }

    function totalBonded() public view returns (uint256) {
        return _state.balance.bonded;
    }

    function totalStaged() public view returns (uint256) {
        return _state.balance.staged;
    }

    function totalClaimable() public view returns (uint256) {
        return _state.balance.claimable;
    }

    function totalDebt() public view returns (uint256) {
        return _state.balance.debt;
    }

    function totalRedeemable() public view returns (uint256) {
        return _state.balance.redeemable;
    }

    function totalCouponUnderlying() public view returns (uint256) {
        return _state.couponUnderlying;
    }

    function totalCoupons() public view returns (uint256) {
        return _state.balance.coupons;
    }

    function totalNet() public view returns (uint256) {
        return dollar().totalSupply().sub(totalDebt());
    }

    function eraStatus() public view returns (Era.Status) {
        return _state.era.status;
    }

    function eraStart() public view returns (uint256) {
        return _state.era.start;
    }

    function totalPhantom() public view returns (uint256) {
        return _state.balance.phantom;
    }

    function totalRewarded() public view returns (uint256) {
        return dollar().balanceOf(address(this)).sub(totalClaimable());
    }

    function paused() public view returns (bool) {
        return _state.paused;
    }

    /**
     * Account
     */

    function balanceOfStaged(address account) public view returns (uint256) {
        return _state.accounts[account].staged;
    }

    function balanceOfClaimable(address account) public view returns (uint256) {
        return _state.accounts[account].claimable;
    }

    function balanceOfBonded(address account) public view returns (uint256) {
        return _state.accounts[account].bonded;
    }

    function balanceOfPhantom(address account) public view returns (uint256) {
        return _state.accounts[account].phantom;
    }

    function balanceOfRewarded(address account) public view returns (uint256) {
        uint256 totalBondedAmount = totalBonded();
        if (totalBondedAmount == 0) {
            return 0;
        }

        uint256 totalRewardedWithPhantom = totalRewarded().add(totalPhantom());
        uint256 balanceOfRewardedWithPhantom =
            totalRewardedWithPhantom.mul(balanceOfBonded(account)).div(totalBondedAmount);

        uint256 balanceOfPhantomAmount = balanceOfPhantom(account);
        if (balanceOfRewardedWithPhantom > balanceOfPhantomAmount) {
            return balanceOfRewardedWithPhantom.sub(balanceOfPhantomAmount);
        }
        return 0;
    }

    function balanceOfCoupons(address account, uint256 epoch) public view returns (uint256) {
        return _state.accounts[account].coupons[epoch];
    }

    function balanceOfCouponUnderlying(address account, uint256 epoch) public view returns (uint256) {
        return _state.couponUnderlyingByAccount[account][epoch];
    }

    function statusOf(address account) public view returns (PoolAccount.Status) {
        if (_state.accounts[account].lockedUntil > epoch()) {
            return PoolAccount.Status.Locked;
        }

        return epoch() >= _state.accounts[account].fluidUntil ? PoolAccount.Status.Frozen : PoolAccount.Status.Fluid;
    }

    function fluidUntil(address account) public view returns (uint256) {
        return _state.accounts[account].fluidUntil;
    }

    function lockedUntil(address account) public view returns (uint256) {
        return _state.accounts[account].lockedUntil;
    }

    function allowanceCoupons(address owner, address spender) public view returns (uint256) {
        return _state.accounts[owner].couponAllowances[spender];
    }

    /**
     * Epoch
     */

    function epoch() public view returns (uint256) {
        return _state.epoch.current;
    }

    function epochStart() public view returns (uint256) {
        return Constants.getEpochStrategy().start;
    }

    function epochPeriod() public view returns (uint256) {
        return Constants.getEpochStrategy().period;
    }

    function epochTime() public view returns (uint256) {
        Constants.EpochStrategy memory current = Constants.getEpochStrategy();

        return epochTimeWithStrategy(current);
    }

    function epochTimeWithStrategy(Constants.EpochStrategy memory strategy) private view returns (uint256) {
        return blockTimestamp().sub(strategy.start).div(strategy.period);
    }

    // Overridable for testing
    function blockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }

    function totalBondedAt(uint256 _epoch) public view returns (uint256) {
        return _state.epochs[_epoch].bonded;
    }

    function bootstrappingAt(uint256 _epoch) public view returns (bool) {
        return _epoch <= Constants.getBootstrappingPeriod();
    }

    /**
     * Governance
     */

    function getCandidateHistory() public view returns (address[] memory) {
        return _state.candidateHistory;
    }

    function recordedVote(address account, address candidate) public view returns (Candidate.Vote) {
        return _state.candidates[candidate].votes[account];
    }

    function startFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].start;
    }

    function periodFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].period;
    }

    function approveFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].approve;
    }

    function rejectFor(address candidate) public view returns (uint256) {
        return _state.candidates[candidate].reject;
    }

    function votesFor(address candidate) public view returns (uint256) {
        return approveFor(candidate).add(rejectFor(candidate));
    }

    function isNominated(address candidate) public view returns (bool) {
        return _state.candidates[candidate].start > 0;
    }

    function isInitialized(address candidate) public view returns (bool) {
        return _state.candidates[candidate].initialized;
    }

    function implementation() public view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }
}
