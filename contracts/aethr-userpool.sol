// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./aethr-nft.sol";

contract UserPool is AccessControlEnumerable, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    IERC20 public BUSD;
    IERC20 public ATH;

    mapping(address => uint256) public poolUser;
    mapping(address => uint256) public poolUserATH;

    uint256 totalPoolUserBUSD;
    uint256 totalPoolUserATH;
    uint256 totalPoolFeeATH;
    uint256 totalPoolFeeBUSD;
    uint256 maxFeeWithdraw = 500;
    uint256 feeWithdraw = 150;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    event WithdrawBUSD(address user, uint256 total, uint256 pool);
    event WithdrawATH(address user, uint256 total, uint256 pool);
    event augmentPoolBUSDEvent(address user, uint256 total, uint256 pool);
    event augmentPoolATHEvent(address user, uint256 total, uint256 pool);
    event converATH (address user, uint256 total);

    constructor(address _BUSD, address _ATH) {
        BUSD = IERC20(_BUSD);
        ATH = IERC20(_ATH);

        BUSD.approve(
            address(this),
            115792089237316195423570985008687907853269984665640564039457584007913129639935
        );

        ATH.approve(
            address(this),
            115792089237316195423570985008687907853269984665640564039457584007913129639935
        );
        
        _setupRole(MINTER_ROLE, _msgSender());
    }

    modifier checkPermission(address _msgSender) {
        require(hasRole(MINTER_ROLE, _msgSender), "Permision");
        _;
    }

    function convertATH(uint256 amount) public nonReentrant 
    {
        uint256 balance = ATH.balanceOf(_msgSender());
        require(balance >= amount, 'Insufficient token amount');

        ATH.transferFrom(_msgSender(), address(this), amount);
        emit converATH(
            _msgSender(),
            amount
        );
    }

    function augmentPoolBUSD(address user, uint256 total)
        public
        checkPermission(_msgSender())
        nonReentrant
    {
        totalPoolUserBUSD += total;
        poolUser[user] += total;
        emit augmentPoolBUSDEvent(user, total, poolUser[user]);
    }

    function augmentPoolATH(address user, uint256 total)
        public
        checkPermission(_msgSender())
        nonReentrant
    {
        totalPoolUserATH += total;
        poolUserATH[user] += total;
        emit augmentPoolATHEvent(user, total, poolUserATH[user]);
    }

    function withdrawBUSD(uint256 total, address user)
        public
        checkPermission(_msgSender())
        nonReentrant
    {
        require(poolUser[user] > total, 'Error token in Pool');
        totalPoolUserBUSD -= total;
        poolUser[user] -= total;
        totalPoolFeeBUSD += ( total / 1000 ) *  feeWithdraw;
        BUSD.transferFrom(address(this), user, ( total / 1000 ) *  feeWithdraw);

        emit WithdrawBUSD(user, total, poolUser[user]);
    }

    function withdrawATH(uint256 total, address user)
        public
        nonReentrant
    {
        require(poolUserATH[user] >= total, 'Error token in Pool');
        totalPoolUserATH -= total;
        poolUserATH[user] -= total;
        ATH.transferFrom(address(this), user, total);
        emit WithdrawBUSD(user, total, poolUserATH[user]);
    }

    function withdrawFee(uint256 amount, address to) public checkPermission(_msgSender()) {
        require(amount <= totalPoolFeeBUSD,'Error token in Pool');
        BUSD.transferFrom(address(this), to, amount);
    }

    function getPoolUser(address user) public view returns (uint256, uint256) {
        return (poolUser[user], poolUserATH[user]);
    }

    function getTotalPoolBUSD() public view returns (uint256) {
        return totalPoolUserBUSD;
    }

    function getTotalPoolATH() public view returns (uint256) {
        return totalPoolUserATH;

    }

    function setRole(address proxy) public checkPermission(_msgSender()) {
        _setupRole(MINTER_ROLE, proxy);
    }
}
