// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract Presale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    event Deposited(
        address indexed user,
        uint256 amount
    );

    event presaleEnabledUpdated(bool enabled);

    IERC20 public busd;
    IERC20 public usdt;
    IERC20 public baby;
    mapping(address => uint256) public deposits;
    address[] public investors;

    address public masterWallet;
    uint256 public totalDepositedBusdBalance;

    uint256 public depositRate = 200; // 1 busd = 200 * baby at first.
    uint256 public totalPresaleAmount = 88888888;
    uint256 public presaledAmount = 0;

    bool presaleEnabled = false;

    constructor(
        IERC20 _busd,
        IERC20 _usdt,
        IERC20 _baby,
        address _masterWallet
    ) public {
        require(address(_busd) != address(0), "BUSD address should not be zero address");
        require(address(_baby) != address(0), "BABY address should not be zero address");
        require(_masterWallet != address(0), "master wallet address should not be zero address");
        busd = _busd;
        usdt = _usdt;
        baby = _baby;
        masterWallet = _masterWallet;
   }

    function depositedUser() public view returns (uint256) {
        return investors.length;
    }
    function updatePresaleRate(uint256 rate) public onlyOwner{
        require(rate > 0, "UpdateSwapRate: Rate is less than Zero");
        depositRate = rate;
    }
    function updatePresalRateAmongPercent() private {
        depositRate = 100 + (totalPresaleAmount - presaledAmount).div(totalPresaleAmount).mul(100);
    }

    function setPresaleEnabled(bool _enabled) public onlyOwner{
        presaleEnabled = _enabled;
        emit presaleEnabledUpdated(_enabled);
    }

    function DepositBusd(uint256 _amount) public nonReentrant {
        require(_amount > 0, "BUSD Amount is less than zero");
        require(presaleEnabled == true, "Presale: Presale is not available");
        uint256 babyTokenAmount = _amount.mul(depositRate);

        busd.safeTransferFrom(msg.sender, masterWallet, _amount);
        baby.safeTransferFrom(masterWallet, msg.sender, babyTokenAmount);

        totalDepositedBusdBalance = totalDepositedBusdBalance + _amount;
        presaledAmount = presaledAmount + babyTokenAmount;
        if(deposits[msg.sender] == 0) {
            investors.push(msg.sender);
        }
        deposits[msg.sender] = deposits[msg.sender] + _amount;
        updatePresalRateAmongPercent();
        emit Deposited(msg.sender, _amount);
    }

    function DepositUsdt(uint256 _amount) public nonReentrant {
        require(_amount > 0, "USDT Amount is less than zero");
        require(presaleEnabled == true, "Presale: Presale is not available");
        uint256 babyTokenAmount = _amount.mul(depositRate);

        usdt.safeTransferFrom(msg.sender, masterWallet, _amount);
        baby.safeTransferFrom(masterWallet, msg.sender, babyTokenAmount);

        totalDepositedBusdBalance = totalDepositedBusdBalance + _amount;
        presaledAmount = presaledAmount + babyTokenAmount;
        if(deposits[msg.sender] == 0) {
            investors.push(msg.sender);
        }
        deposits[msg.sender] = deposits[msg.sender] + _amount;
        updatePresalRateAmongPercent();
        emit Deposited(msg.sender, _amount);
    }

    function updateBabyToken(IERC20 _baby) public onlyOwner{
        require(address(_baby) != address(0), "OldVgdToken address should not be zero address");
        baby = _baby;
    }

    function updateMasterWalletAddress(address _newWalletAddr) public onlyOwner{
        require(address(_newWalletAddr) != address(0), "Wallet address should not be zero address");
        masterWallet = _newWalletAddr;
    }
}