pragma solidity ^0.8.0;

// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Arrays.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/*

  /$$$$$$   /$$$$$$  /$$$$$$$  /$$   /$$             
 /$$__  $$ /$$__  $$| $$__  $$| $$  | $$             
| $$  \__/| $$  \ $$| $$  \ $$| $$  | $$             
| $$ /$$$$| $$$$$$$$| $$$$$$$/| $$  | $$             
| $$|_  $$| $$__  $$| $$____/ | $$  | $$             
| $$  \ $$| $$  | $$| $$      | $$  | $$             
|  $$$$$$/| $$  | $$| $$      |  $$$$$$/             
 \______/ |__/  |__/|__/       \______/              
                                                     
                                                     
                                                     
  /$$$$$$   /$$                     /$$ /$$          
 /$$__  $$ | $$                    | $$|__/          
| $$  \__//$$$$$$   /$$   /$$  /$$$$$$$ /$$  /$$$$$$ 
|  $$$$$$|_  $$_/  | $$  | $$ /$$__  $$| $$ /$$__  $$
 \____  $$ | $$    | $$  | $$| $$  | $$| $$| $$  \ $$
 /$$  \ $$ | $$ /$$| $$  | $$| $$  | $$| $$| $$  | $$
|  $$$$$$/ |  $$$$/|  $$$$$$/|  $$$$$$$| $$|  $$$$$$/
 \______/   \___/   \______/  \_______/|__/ \______/ 

*/                           

contract ATH is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable {
    
    using SafeMath for uint;

    uint256 private totalTokens;

    constructor() ERC20("AETHR Token", "ATH") {
        totalTokens = 790 * 10 ** 6 * 10 ** uint256(decimals()); // 790M
        _mint(owner(), totalTokens);  
    }

    function snapshot() external onlyOwner {
        _snapshot();
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function getBurnedAmountTotal() external view returns (uint256 _amount) {
        return totalTokens.sub(totalSupply());
    }
}