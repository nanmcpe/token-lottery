// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./token/ERC20/IERC20.sol";
import "./token/ERC20/SafeERC20.sol";
import "./interface/ILotteryReferral.sol";
import "./access/Ownable.sol";

contract LotteryReferral is ILotteryReferral, Ownable {
    using SafeERC20 for IERC20;

    // BUSD TOKEN
    IERC20 public rewardToken;

    mapping(address => bool) public operators;
    mapping(address => address) public referrers; // user address => referrer address
    mapping(address => uint256) public referralsCount; // referrer address => referrals count
    mapping(address => uint256) public totalReferralCommissions; // referrer address => total referral commissions

    event ReferralRecorded(address indexed user, address indexed referrer);
    event ReferralCommissionRecorded(address indexed referrer, uint256 commission);
    event OperatorUpdated(address indexed operator, bool indexed status);
    event Claim(address indexed user, uint256 amount);

    constructor(
        IERC20 _rewardToken
    ) public {
        rewardToken = _rewardToken;
    }

    modifier onlyOperator {
        require(operators[msg.sender], "Operator: caller is not the operator");
        _;
    }

    function recordReferral(address _user, address _referrer) public override onlyOperator {
        if (_user != address(0)
            && _referrer != address(0)
            && _user != _referrer
            && referrers[_user] == address(0)
        ) {
            referrers[_user] = _referrer;
            referralsCount[_referrer] += 1;
            emit ReferralRecorded(_user, _referrer);
        }
    }

    function recordReferralCommission(address _referrer, uint256 _commission) public override onlyOperator {
        if (_referrer != address(0) && _commission > 0) {
            totalReferralCommissions[_referrer] += _commission;
            emit ReferralCommissionRecorded(_referrer, _commission);
        }
    }

    function claimReward() public {
        uint256 reward = pendingReward(msg.sender);
        if (reward > 0) {
            rewardToken.transfer(address(msg.sender), reward);
            emit Claim(msg.sender, reward);     
        }
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) public view returns (uint256) {
        return totalReferralCommissions[_user];
    }

    // Get the referrer address that referred the user
    function getReferrer(address _user) public override view returns (address) {
        return referrers[_user];
    }

    // Update the status of the operator
    function updateOperator(address _operator, bool _status) external onlyOwner {
        operators[_operator] = _status;
        emit OperatorUpdated(_operator, _status);
    }

    // Owner can drain tokens that are sent here by mistake
    function drainBEP20Token(IERC20 _token, uint256 _amount, address _to) external onlyOwner {
        _token.safeTransfer(_to, _amount);
    }
}