// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;
    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    mapping(address => uint256) public balances;
    uint256 public constant threshold = 0.1 ether;
    event Stake(address _add, uint256 _amt);
    function stake() public payable {
        require(block.timestamp < deadline, "Deadline is Reached ! ");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
    uint256 public deadline = block.timestamp + 1 days;
    bool public openForWithdraw;
    bool public executed;

    modifier notCompleted() {
        require(block.timestamp >= deadline, "Deadline is not Reached !");
        _;
    }
    function execute() public notCompleted{
        require(!executed, " already Excecuted");
        executed = true;
        if (address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        } else {
            openForWithdraw = true;
        }
    }
    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw() public notCompleted{
        require(openForWithdraw, "Excecute First!");
        require(balances[msg.sender] > 0, "No ether is staked");
        (bool sent, bytes memory data) = (msg.sender).call{
            value: balances[msg.sender]
        }("");
        delete balances[msg.sender];
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
    }
}
