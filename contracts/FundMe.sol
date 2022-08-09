//SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol"; // all math in this contract

error FundMe__NotOwner();

/** @title A contract for crowd funding
 * @author Bryce Landers
 * @notice This contract is to demo a sample funding contract
 * @dev This implements price feed as our library
 */
contract FundMe {
    using PriceConverter for uint256;

    // State Variables - storage variables
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] private s_funders; // Array of senders
    mapping(address => uint256) private s_addressToAmountFunded; // each address and how much they actually funded.
    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed; // paramaterized priceFeed to change the address based on the chainid.

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner(); // underscore represents do the rest of the code
        _;
    }

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // write tests for these
    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     fund();
    // }

    /**
     * @notice This function funds this contract
     * @dev This implements price feed as our library
     */
    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didnt sent enough!!"
        );
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        //starting index, ending index, step amount
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0); // reset the array
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }(""); // actually withdraw ether.
        require(callSuccess, "Call Failed");
    }

    // saving the storage variable to the memory variable then reading from memory vs storage
    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunder(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
// mappings cant be in memory
