//SPDX-License-Identifier: MIT

pragma solidity ^0.8;

contract StakingRewards {
    // Variable to hold interfaces for rewards and staking token.
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint public rewardRate = 100;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;

    // MAPPINGS
    mapping(address=>uint) public userRewardPerTokenPaid;
    mapping(address=>uint) public rewards;
    mapping(address=>uint) private _balances;

    uint private _totalSupply;

    // CONSTRUCTOR
    // Deploy Staking & Rewards token separately and provide the
    // addresses of those contracts to deploy the StakingReward contract
    // During construction of the contract, we are saving stakingToken &
    // rewardsToken address as global variable.
    // Provide addresses like 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    // MODIFIER
    // Modifier to updae reward of an account
    // Provide account address as input like 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[account] = earned(account);
        userRewardPerTokenPaid[account] = rewardPerTokenStored;
        _;
    }

    // Functions
    // View only function to see the reward per token
    // calculated by formula: reward per token = existing reward +
    //  (current time - lastUpdateTime) * rewardRate * 1e18 / totalSupply
    // the output value is in wei
    function rewardPerToken() public view returns(uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + (((block.timestamp - lastUpdateTime) * rewardRate * 1e18) / _totalSupply);
    }

    // Total earned wei for the provided address.
    // Example address: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    function earned(address account) public view returns(uint) {
        return ((_balances[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    // Stake provided quantity of token
    function stake(uint _amount) external updateReward(msg.sender) {
        _totalSupply += _amount;
        _balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount);
    }

    // Withdraw token from own account.
    function withdraw(uint _amount) external updateReward(msg.sender) {
        _totalSupply -= _amount;
        _balances[msg.sender] -= _amount;       
        stakingToken.transfer(msg.sender, _amount);
    }

    // Get reward tokens transferred to own account.
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }
}

    // Interface for the ERC20 tokens
interface IERC20 {
    function totalSupply() external view returns(uint);
    function balanceOf(address account) external view returns(uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns(uint);
    function approve(address spender, uint amount) external returns(bool);
    function transferFrom(address spender, address recipient, uint amount) external returns(bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
