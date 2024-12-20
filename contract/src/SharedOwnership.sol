// contracts/MyNFT.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SharedOwnership is ERC20 {

    address[] public owners;
    mapping (address => bool) isOwner;

    bool inPayment;

    constructor(
        address[] memory _owners, 
        uint256[] memory allocation
    ) ERC20("OWNERSHIP", "OWS") {
        for (uint256 i = 0; i < owners.length; i++) {
            owners.push(_owners[i]);
            _mint(_owners[i], allocation[i]);
        }
    }

    function removeOwner(address previousOwner) internal {
        for (uint256 i = 0; i < owners.length; i++) {
            if (previousOwner == owners[i]) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                return;
            }
        }
    }

    function _update(address from, address to, uint256 value) internal override {
        super._update(from, to, value);

        // Check if 'from' is still an owner 
        if (balanceOf(from) == 0) {
            removeOwner(from);
        }

        // Check if 'to' is already an owner
        if (!isOwner[to]) {
            isOwner[to] = true;
            owners.push(to);
        }

    }

    
    function pay() public {
        require(!inPayment, "Invalid state");
        inPayment = true;
        
        uint balance = address(this).balance;

        for (uint256 i = 0; i < owners.length; i++) {
            uint share = balance * this.balanceOf(owners[i]) / this.totalSupply();
            (bool sent, bytes memory data) = owners[i].call{value: share}("");
            // FIXME :: optimzied future version / what happened if invalid address 
        }   

        inPayment = false;
    }

    // Accept to received fund
    receive() external payable {}
}
