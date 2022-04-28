// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./aethr-nft.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AETHR_AWAKEN {
    using SafeERC20 for IERC20;
    IERC20 public ATH;
    AETHR_NFT public FactoryNFT;

    address owner;

    uint256 public _feeAwaken;

    constructor(address _Factory, address _ATHToken) {
        owner = msg.sender;
        FactoryNFT = AETHR_NFT(_Factory);
        ATH = IERC20(_ATHToken);
        ATH.approve(
            address(this),
            115792089237316195423570985008687907853269984665640564039457584007913129639935
        );
    }

    event Awaken(
        uint256 indexed tokenId,
        uint256[] meterial,
        address wallet_address,
        uint256 star
    );

    event BurnNft(uint256 indexed tokenId, address wallet_address);

    modifier onlyOwner(address sender) {
        require(sender == owner, "Is not Owner");
        _;
    }

    modifier checkOwnerRequirements(uint256[] calldata arrayTokenId) {
        for (uint256 index = 0; index < arrayTokenId.length; index++) {
            require(
                FactoryNFT.ownerOf(arrayTokenId[index]) == msg.sender,
                "Is not Owner"
            );
            require(
                FactoryNFT.isLocked(arrayTokenId[index]) == false,
                "Token is locked"
            );
        }
        _;
    }

    /**
     * @dev Set fee awaken
     */
    function updateFeeAwaken(uint256 feeAwaken) public onlyOwner(msg.sender) {
        _feeAwaken = feeAwaken;
    }

    function awaken(
        uint256[] calldata material,
        uint256 main,
        uint256 star
    ) public virtual checkOwnerRequirements(material) {
        require(FactoryNFT.ownerOf(main) == msg.sender, "Is not Owner");
        require(
            ATH.balanceOf(msg.sender) > _feeAwaken,
            "Awaken: Invalid token amount"
        );
        require(
            ATH.allowance(msg.sender, address(this)) > _feeAwaken,
            "Awaken: Invalid token allowance"
        );
        for (uint256 index = 0; index < material.length; index++) {
            FactoryNFT.safeTransferFrom(
                msg.sender,
                0x000000000000000000000000000000000000dEaD,
                material[index]
            );
            emit BurnNft(material[index], msg.sender);
        }
        ATH.transferFrom(msg.sender, address(this), _feeAwaken);
        emit Awaken(main, material, msg.sender,star);
    }
}