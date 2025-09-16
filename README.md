🎰 Raffle Smart Contract

A decentralized lottery (raffle) smart contract built with Solidity, using Chainlink VRF v2.5 for verifiable randomness and Foundry for testing and deployment.

📝 Project Overview

This project implements a secure and decentralized raffle contract where users can participate by sending ETH. At specified intervals, a random winner is selected automatically using Chainlink VRF to ensure fairness.

Key features include:

✅ Minimum entrance fee requirement

✅ Storing participants and tracking entries

✅ Verifiable randomness using Chainlink VRF v2.5

✅ Automated winner selection

✅ Comprehensive unit testing with Foundry

⚙️ Features

Minimum Entry Fee --> Players must send a minimum ETH amount to enter.
Track Participants --> Players are stored in a dynamic array and can be queried.
Verifiable Randomness -->	Winner selection uses Chainlink VRF v2.5 for tamper-proof randomness.
Automated Draw -->	Winners are picked automatically after the raffle interval.
Events -->	Emits RaffleEntered and WinnerPicked for easy tracking on-chain.
Tests -->	Unit tests for all core functionalities using Foundry.


🛠 Tech Stack

Solidity 0.8.19 – Smart contract programming

Chainlink VRF v2.5 – Random number generator

Foundry – Smart contract testing & deployment

EVM Compatible Networks – Sepolia, Goerli, etc.

Forge Std – Testing utilities (vm.prank, vm.deal, vm.hoax)


📂 File Structure
├── src/
│   └── Raffle.sol             # Main raffle contract
├── script/
│   ├── DeployRaffle.s.sol     # Deployment script
│   └── HelperConfig.s.sol     # Network configuration
├── test/
│   └── unit/
│       └── RaffleTest.t.sol   # Unit tests
├── lib/
│   └── chainlink-brownie-contracts
└── README.md

⚡ How it Works

Players send ETH via enterRaffle() to participate.

The contract keeps track of participants in s_players.

After the raffle interval passes, Chainlink VRF is called in performUpkeep() to generate a random number.

A winner is selected using modulo arithmetic:

uint256 indexOfWinner = randomWords[0] % s_players.length;

Winner receives the accumulated ETH, and the raffle resets.


🧪 Running Tests

Run unit tests:

forge test


Tests include:

Raffle opens correctly

Reverts if player sends insufficient ETH

Player entries are recorded

Winner selection and payout

🚀 Deployment

Deploy on any EVM-compatible network:

forge script script/DeployRaffle.s.sol --broadcast --rpc-url <RPC_URL> --private-key <PRIVATE_KEY>

🔧 Cheatcodes in Tests

vm.prank(address) – sets msg.sender for the next call

vm.deal(address, amount) – sets ETH balance

vm.hoax(address, amount) – combines prank + deal

📌 Notes

This contract uses custom errors for gas efficiency.

Events are emitted for all player entries and winner selections.

Chainlink VRF integration ensures fairness and transparency.
