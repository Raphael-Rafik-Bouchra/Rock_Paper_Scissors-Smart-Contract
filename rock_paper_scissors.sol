// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract RockPaperScissors {
    address public participant1;
    address public participant2;
    uint256 public reward;
    uint256 public submit_deadline;
    uint256 public reveal_deadline;
    bool public completed;
    bytes32 public commitment1;
    bytes32 public commitment2;
    uint256 public result1;
    uint256 public result2;
    
    constructor(address _participant1, address _participant2) payable {
        require(msg.value > 0, "Reward must be greater than zero.");
        require(_participant1 != address(0) && _participant2 != address(0), "Participants' addresses must be valid.");
        require(_participant1 != _participant2, "Participants' addresses must be distinct.");
        participant1 = _participant1;
        participant2 = _participant2;
        reward = msg.value;
        submit_deadline = block.timestamp + 1 hours;
        reveal_deadline = submit_deadline + 1 hours;
        completed = false;
        result1 = 0;
        result2 = 0;
    }
    
    function submitChoice(bytes32 commitment) public {
        require(msg.sender == participant1 || msg.sender == participant2, "Only participants can submit their choices.");
        require(block.timestamp <= submit_deadline, "Deadline has passed.");
        require(!completed, "The game has already been played.");

        if (msg.sender == participant1) {
            require(commitment1 == bytes32(0), "Participant 1 has already submitted their commitment.");
            require(commitment != commitment2, "Can Not commit the same commitment of Participant 2");
            commitment1 = commitment;
        } else {
            require(commitment2 == bytes32(0), "Participant 2 has already submitted their commitment.");
            require(commitment != commitment1, "Can Not commit the same commitment of Participant 1");
            commitment2 = commitment;
        }
    }

    function revealChoice(uint256 choice, bytes32 salt) public {
        require(msg.sender == participant1 || msg.sender == participant2, "Only participants can reveal their choices.");
        require(submit_deadline < block.timestamp && block.timestamp <= reveal_deadline, "Reveal deadline has passed or reveal phase has not started.");
        require(!completed, "The game has already been played.");

        bytes32 expectedCommitment;
        if (msg.sender == participant1) {
            expectedCommitment = keccak256(abi.encodePacked(choice, salt));
            require(commitment1 == expectedCommitment, "Invalid commitment.");
            result1 = choice;
        } else {
            expectedCommitment = keccak256(abi.encodePacked(choice, salt));
            require(commitment2 == expectedCommitment, "Invalid commitment.");
            result2 = choice;
        }

        if (result1 != 0 && result2 != 0) {
            completed = true;
        }
    }
    
    function getWinner() public view returns (address) {
        require(completed, "The game has not been played yet.");

        if(result1 == 0){
            return participant2;
        } else if (result2 == 0){
            return participant1;
        } else if(result1 == 1 && result2 == 2){
            return participant2;
        } else if (result1 == 1 && result2 == 3){
            return participant1;
        } else if (result1 == 2 && result2 == 3){
            return participant1;
        } else if (result1 == 2 && result2 == 1){
            return participant1;
        }else if (result1 == 3 && result2 == 1){
            return participant2;
        } else if (result1 == 3 && result2 == 2){
            return participant2;
        } else{
            return address(0); // Tie.
        }
    }
    
    function distributeReward() public {
        require(completed, "The game has not been played yet.");

        completed = true;
        if (getWinner() == address(0)){ //Tie, Then split the reward
            bool success = payable(participant1).send(reward / 2);
            require(success, "Failed to send reward to participant1.");
            success = payable(participant2).send(reward / 2);
            require(success, "Failed to send reward to participant2.");
        } else if (getWinner() == participant1){ //winner is participant1
            bool success = payable(participant1).send(reward);
            require(success, "Failed to send reward to winner.");
        } else { //winner is participant2
            bool success = payable(participant2).send(reward);
            require(success, "Failed to send reward to winner.");
        }
    }
}