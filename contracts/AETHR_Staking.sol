// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AETHR_Staking is Ownable, ReentrancyGuard {
    // ONLY ALLOW BUSD
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    IERC20 public ATH;

    // EVENT
    event NewTotalATHStaking(uint256 _totalATHStaking);
    event Deposit(address user, uint256 amount, uint256 start);
    event Claim(address user, uint256 amount);

    // STATE
    struct UserInfo {
        uint256 amount;
        uint256 startTime;
    }

    struct History {
        uint256 receivedAmount;
        UserInfo[] stakingHistory;
    }
    uint256 public rewardInBUSD;
    uint256 public maxATHStaking;
    uint256 public totalATHStaking;

    uint256[] public lockedTimeInDay;
    uint256[] public lockedPercent;

    uint256 public constant SECONDS_IN_DAY = 86400;

    mapping(address => History) public usersInfo;

    constructor(
        address _BUSD,
        address _ATHToken,
        uint256 _rewardInBUSD,
        uint256 _totalATHStaking,
        uint256[] memory _lockedTimeInDay, // 30, 30,30
        uint256[] memory _lockedPercent // 2000,3000,5000 <-> 20%, 30%,50%
    ) {
        BUSD = IERC20(_BUSD);
        ATH = IERC20(_ATHToken);

        rewardInBUSD = _rewardInBUSD;
        maxATHStaking = _totalATHStaking;
        require(
            _lockedTimeInDay.length == _lockedPercent.length,
            "Incorrect time lock"
        );
        lockedTimeInDay = _lockedTimeInDay;
        lockedPercent = _lockedPercent;
    }

    function setTotalATHStaking(uint256 _totalATHStaking) public onlyOwner {
        totalATHStaking = _totalATHStaking;
        emit NewTotalATHStaking(_totalATHStaking);
    }

    function deposit(uint256 amount) public {
        ATH.safeTransferFrom(msg.sender, address(this), amount);
        usersInfo[msg.sender].stakingHistory.push(
            UserInfo(amount, block.timestamp)
        );
        totalATHStaking += amount;
        require(
            totalATHStaking <= maxATHStaking,
            "can not stake to this amount"
        );

        emit Deposit(msg.sender, amount, block.timestamp);
    }

    function claim() public {
        uint256 _amountInATH = viewClaimable(msg.sender, block.timestamp);
        uint256 _amountInBUSD = (_amountInATH * rewardInBUSD) / (10**18);
        BUSD.safeTransfer(msg.sender, _amountInBUSD);
        usersInfo[msg.sender].receivedAmount += _amountInATH;

        emit Claim(msg.sender, _amountInBUSD);
    }

    function getUserInfo(address _user)
        public
        view
        returns (UserInfo[] memory)
    {
        return usersInfo[_user].stakingHistory;
    }

    function viewClaimable(address _user, uint256 _to)
        public
        view
        returns (uint256)
    {
        uint256 _amount;
        for (uint256 i = 0; i < usersInfo[_user].stakingHistory.length; i++) {
            UserInfo memory data = usersInfo[_user].stakingHistory[i];
            if (_to > data.startTime) {
                for (uint256 j = 0; j < lockedTimeInDay.length; j++) {
                    if (
                        data.startTime + lockedTimeInDay[j] * SECONDS_IN_DAY <=
                        _to
                    ) {
                        _amount += (data.amount * lockedPercent[j]) / 10000;
                        data.startTime += lockedTimeInDay[j] * SECONDS_IN_DAY;
                        if (j == lockedTimeInDay.length - 1)
                            _amount = data.amount;
                    } else break;
                }
            }
        }
        return _amount - usersInfo[_user].receivedAmount;
    }
}
