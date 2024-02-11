// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {ITicketNFT} from "./interfaces/ITicketNFT.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {TicketNFT} from "./TicketNFT.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol"; 
import {ITicketMarketplace} from "./interfaces/ITicketMarketplace.sol";
import "hardhat/console.sol";

contract TicketMarketplace is ITicketMarketplace {
    // your code goes here (you can do it!)
    address ownerAddress;
    address erc20SampleCoinAddress;
    TicketNFT ticketNFT;
    uint128 currEventId;

    struct Event {
        uint128 maxTickets;
        uint256 pricePerTicket;
        uint256 pricePerTicketERC20;
        uint256 nextTicketToSell;
    }
    mapping(uint128 => Event) eventList;

    constructor(address newSampleCoinAddress){
        ownerAddress = msg.sender;
        erc20SampleCoinAddress = newSampleCoinAddress;
        currEventId = 0;
        ticketNFT = new TicketNFT(address(this));
    }

    function owner() external view returns (address){
        return address(ownerAddress);
    }
    function nftContract() external view returns (address) {
        return address(ticketNFT);
    }
    function ERC20Address() external view returns (address) {
        return address(erc20SampleCoinAddress);
    }
    function currentEventId() external view returns (uint128) {
        return uint128(currEventId);
    }
    function events(uint128 eventId) external view returns (Event memory) {
        return eventList[eventId];
    }

    function createEvent(uint128 maxTickets, uint256 pricePerTicket, uint256 pricePerTicketERC20) public {
        if(msg.sender != ownerAddress){
            revert("Unauthorized access");
        }
        
        eventList[currEventId] = Event(maxTickets, pricePerTicket, pricePerTicketERC20, 0);
        
        emit EventCreated(currEventId, maxTickets, pricePerTicket, pricePerTicketERC20); 
        currEventId += 1;
    }

    function setMaxTicketsForEvent(uint128 eventId, uint128 newMaxTickets) external{
        if(msg.sender != ownerAddress){
            revert("Unauthorized access");
        }
        
        if(eventList[eventId].maxTickets > newMaxTickets){
            revert("The new number of max tickets is too small!");
        }
        eventList[eventId].maxTickets = newMaxTickets;
        emit MaxTicketsUpdate(eventId, newMaxTickets);
    }

    function setPriceForTicketETH(uint128 eventId, uint256 price) external{
        if(msg.sender != ownerAddress){
            revert("Unauthorized access");
        }
        eventList[eventId].pricePerTicket = price;
        emit PriceUpdate(eventId, price, "ETH");
    }

    function setPriceForTicketERC20(uint128 eventId, uint256 price) external{
        if(msg.sender != ownerAddress){
            revert("Unauthorized access");
        }

        eventList[eventId].pricePerTicketERC20 = price;
        emit PriceUpdate(eventId, price, "ERC20");
    }

    function buyTickets(uint128 eventId, uint128 ticketCount) payable external{
        uint256 numberTickets = type(uint256).max / eventList[eventId].pricePerTicket;

        if(ticketCount > numberTickets){
            revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
        }

        if(eventList[eventId].maxTickets <= eventList[eventId].nextTicketToSell + ticketCount){
            revert("We don't have that many tickets left to sell!");
        }

        uint256 totalEventPrice = ticketCount * eventList[eventId].pricePerTicket;
        if(msg.value <= totalEventPrice){
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }

        for(uint128 i = 0; i < ticketCount; i++){
            uint256 nftId = (uint256(eventId) << 128)  + uint256(eventList[eventId].nextTicketToSell) + i;
            ticketNFT.mintFromMarketPlace(msg.sender, nftId);
        }

        eventList[eventId].nextTicketToSell += ticketCount;

        emit TicketsBought(eventId, ticketCount, "ETH");
    }

    function buyTicketsERC20(uint128 eventId, uint128 ticketCount) public{
        uint256 numberTickets = type(uint256).max / eventList[eventId].pricePerTicketERC20;

        if(ticketCount > numberTickets){
            revert("Overflow happened while calculating the total price of tickets. Try buying smaller number of tickets.");
        }
        
        if(eventList[eventId].maxTickets <= eventList[eventId].nextTicketToSell + ticketCount){
            revert("We don't have that many tickets left to sell!");
        }

        if(uint256(IERC20(erc20SampleCoinAddress).balanceOf(msg.sender)) <=(uint256(ticketCount * eventList[eventId].pricePerTicketERC20))){
            revert("Not enough funds supplied to buy the specified number of tickets.");
        }

        for(uint128 i = 0; i < ticketCount; i++){
            uint256 nftId = (uint256(eventId) << 128)  + uint256(eventList[eventId].nextTicketToSell) + i;
            ticketNFT.mintFromMarketPlace(msg.sender, nftId);
        }
        
        eventList[eventId].nextTicketToSell += ticketCount;
        IERC20(erc20SampleCoinAddress).transferFrom(msg.sender, address(this), (ticketCount * eventList[eventId].pricePerTicketERC20));
        emit TicketsBought(eventId, ticketCount, "ERC20");
    }

    function setERC20Address(address newERC20Address) external{
        if(msg.sender != ownerAddress){
            revert("Unauthorized access");
        }
        erc20SampleCoinAddress = newERC20Address;
        emit ERC20AddressUpdate(newERC20Address);
    }
}