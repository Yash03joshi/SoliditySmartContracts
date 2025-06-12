// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {PriceConverter} from "./PriceConverter.sol";


error notOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address [] public funders;
    mapping (address funder => uint256 amountFunded) public fundersWithAmounts;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable  {
        require(msg.value.getConversionRate() >= MINIMUM_USD , "didn't send enough ETH");   
        funders.push(msg.sender);
        fundersWithAmounts[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex<funders.length ; funderIndex++){
            address funder = funders[funderIndex];
            fundersWithAmounts[funder] = 0;
        }
        funders = new address[](0);
        // bool sendSuccess =  payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"send failed");

        (bool sendSuccess,) = payable (msg.sender).call{value:address(this).balance}("");
        require(sendSuccess,"Call failed");
    }

    modifier onlyOwner () {
        require(msg.sender == i_owner, "only owner can call this function!");
        if (msg.sender != i_owner) {
            revert notOwner(); 
        }
        _;
    }

    receive() external payable {
        fund();
     }

     fallback() external payable {
        fund();
      }
}