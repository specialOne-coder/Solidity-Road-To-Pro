// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//@title EtherWallet
//@version 0.1
//@author Ferdinand
//@notice simple wallet ethereum onchain
contract EtherWallet {

    address payable public owner; // owner of the wallet

    constructor(){
        owner = payable(msg.sender); // owner is the sender of the transaction (creating the wallet)
    }

    receive() external payable {} // receive ether

    modifier onlyOwner{ // modifier (only owner can call function)
        require(msg.sender == owner,"not Owner");
        _;
    }

    //@notice withdraw ether
    //@param _value amount of ether to withdraw
    function withdraw(uint _amount) external onlyOwner {
        payable(msg.sender).transfer(_amount); // transfer ether to sender
    }

    //@notice get balance
    function getBalance() external view returns (uint) {
        return address(this).balance; // return balance of the wallet
    }

}