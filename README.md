#Rock-Paper-Scissors Smart Contract

This is a smart contract written in Solidity that enables two participants to run a rock-paper-scissors game to decide the distribution of a reward. The contract assumes that the two participants' addresses are known in advance, and the contest manager (the contract creator) is responsible for depositing the reward into the contract.

##Assumptions:
- Choice submission deadline is 1 Hour.
- Reveal deadline is 1 Hour after the choice submission deadline.
- the participants will not submit the same commitment as the other participant.
- The participants can commit only one time.

##High-level explanation of the smart contract:
- When deploying the contract, the addresses of the two participants are provided, and an initial reward amount is sent to the contract. The participants' addresses are stored, along with the reward amount and deadlines for submitting and revealing choices.
- To play the game, the participants follow a two-step process: submitting their choice commitment and revealing their choice. In the submission phase, each participant must generate a commitment by hashing their choice with a random salt and submit it to the contract using the "submitChoice" function. The commitment ensures that participants cannot change their choice after submitting it.
- In the reveal phase, participants use the "revealChoice" function to reveal their choice and the previously used salt. The contract verifies the commitment by rehashing the choice and salt and comparing it to the stored commitment. If the commitment is valid, the participant's choice is recorded.
- Once both participants have revealed their choices, the contract determines the winner using a predefined set of rules for Rock, Paper, Scissors. The "getWinner" function can be used to retrieve the address of the winner.
- Finally, the "distributeReward" function is called to distribute the reward to the winner. If there is a tie, the reward is split equally between the participants. The function sends the corresponding amount of Ether to the winner's address.
