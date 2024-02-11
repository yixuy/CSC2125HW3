// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ITicketNFT} from "./interfaces/ITicketNFT.sol";
// Uncomment this line to use console.log
import "hardhat/console.sol";

contract TicketNFT is ERC1155, ITicketNFT { 
    address ownerAddress;
    
    constructor (address ticketAddress) ERC1155("https://api.example.com/tickets/{id}.json") {
        ownerAddress = ticketAddress;
    }

    function owner() external view returns (address){
        return address(ownerAddress);
    }
    

    function mintFromMarketPlace(address to, uint256 nftId) external override{
        _mint(to, nftId, 1, "");
    }
}






