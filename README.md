# BigTime Item Auction - Smart Contract

This project contains a smart contract for conducting **character upgrade item auctions** within the Big Time game ecosystem.  
The contract is deployed on the **Sepolia** network and meets all technical requirements for Module 2.

##  Description

The `BigTimeItemAuction` contract allows users to compete for a unique Big Time item through an auction system:

- Bids must be at least **5% higher** than the previous one.
- The auction is extended by **10 minutes** if a valid bid is placed in the last 10 minutes.
- **Partial refunds** are allowed during the auction, and full refunds (minus commission) for non-winners after it ends.

---

## Main Features

- `constructor(string _itemName, uint256 _durationSeconds)`  
  Initializes the auction with the item name and duration (in seconds).

- `placeBid()`  
  Allows users to bid by sending ETH. Requires that the bid be at least 5% higher than the current highest.

- `getWinner()`  
  Returns the auction winner and the amount of their bid.

- `getAllBids()`  
  Returns all addresses that placed bids and the total amount each one has bid.

- `withdraw()`  
  Allows non-winning users to withdraw their funds after the auction ends.

- `partialRefund()`  
  Allows users to recover amounts from bids made before their last valid one while the auction is still active.

- `finalizeAuction()`  
  Ends the auction, emits a closing event, and transfers funds (after subtracting commission).

- `emergencyWithdraw(uint256 amount)`  
  Only the owner can withdraw funds in case of an emergency.

---

##  Events

- `event NewBid(address indexed bidder, uint256 amount);`  
  Emitted every time a valid new bid is placed.

- `event AuctionEnded(address winner, uint256 amount);`  
  Emitted when the auction ends, showing the winner and the final amount.

---

##  Security

- Use of modifiers `onlyOwner`, `auctionActive`, `auctionFinished`.
- All `require` validations placed at the beginning of each function.
- Reentrancy protection implemented in refund logic.
- 2% commission is calculated and deducted when the auction ends.

---

##  Etherscan Contract

**Address (Sepolia):**  
[https://sepolia.etherscan.io/address/0xYOUR_CONTRACT_ADDRESS](https://sepolia.etherscan.io/address/0xad3c955505db059021910daa9538e327e5512377)  
Verified source code

---

##  Network and Tools Used

- **Test Network:** Sepolia Testnet  
- **IDE:** Remix Ethereum  
- **Language:** Solidity ^0.8.20  
- **Wallet:** MetaMask  
- **Verification:** Etherscan

---



