// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

/* Imports */
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/* Errors */
error NFTMarketplace__ListingPriceIsNotMet(string message);

contract NFTMarketplaceScalable is ReentrancyGuard {

    address payable private owner;
    uint256 listingPrice = 0.025 * (10 ** 18); // This is the base price every seller has to pay for every listing.

    IERC20 public tradingToken;

    constructor(address _erc20Address) {
        tradingToken = IERC20(_erc20Address);
        owner = payable(msg.sender);
    }

    event ListingPayment(
        address from,
        bool paymentDone
    );

    event ItemPayment(
        address from,
        address to,
        bool paymentDone
    );

    function getListingPrice() external view returns (uint256) {
        return listingPrice;
    }

    // Payment to owner for listing in marketplace
    function marketplaceListingPayment() public nonReentrant {
        // check if listingPrice is approved by the sender
        if (tradingToken.allowance(msg.sender, address(this)) < listingPrice) {
            revert NFTMarketplace__ListingPriceIsNotMet("Listing price is not met");
        }

        tradingToken.transferFrom(msg.sender, owner, listingPrice);
        emit ListingPayment(
            msg.sender,
            true
        );
    }

    // Resell
    function marketplaceItemPayment(
        address to, 
        uint _amount
    ) public nonReentrant {
        // check if payer has approved the token amount
        if (tradingToken.allowance(msg.sender, address(this)) < (_amount * (10 ** 18))) {
            revert NFTMarketplace__ListingPriceIsNotMet("Item price is not met");
        }

        tradingToken.transferFrom(msg.sender, to, (_amount * (10 ** 18)));
        emit ItemPayment(
            msg.sender,
            to,
            true
        );
    }
}
