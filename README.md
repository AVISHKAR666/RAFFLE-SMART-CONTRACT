
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
🎲**Decentralized Raffle Smart Contract — Sepolia (Foundry + Chainlink VRF v2.5)** 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Solidity License: MIT

This repository contains the smart contract for a decentralized raffle (lottery), developed as part of my Web3 learning journey using Foundry and Chainlink VRF v2.5. The project demonstrates practical smart contract development skills, provably fair randomness, and automated upkeep through Chainlink.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🚀 Project Overview

This project implements a fully decentralized raffle system on the Sepolia testnet.

Players can enter by paying a fixed fee.

Chainlink Automation periodically checks raffle conditions.

Chainlink VRF v2.5 ensures provably fair randomness for winner selection.

The winner automatically receives the prize pool, and the raffle resets for the next round.

This project highlights how to integrate Foundry tooling + Chainlink services to build robust, transparent, and secure decentralized apps (dApps).

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🛠 Tech Stack

Solidity 0.8.19 – Smart contract programming

Chainlink VRF v2.5 – Random number generator

Foundry – Smart contract testing & deployment

EVM Compatible Networks – Sepolia, Goerli, etc.

Forge Std – Testing utilities (vm.prank, vm.deal, vm.hoax)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

✨ Features

Solidity Smart Contract (security-focused and gas-optimized).

Foundry Development Environment (fast compile, test, deploy).

Chainlink VRF v2.5 Integration for verifiable randomness.

Chainlink Automation Integration for decentralized upkeep.

Etherscan Verification for transparency.

Comprehensive Testing (unit, integration, forked).

Gas Reports for optimization.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

⚙️ Contract Parameters

Entrance Fee: 0.01 ETH

Interval (Chainlink Automation): 30 seconds

Callback Gas Limit: 500,000

Chainlink (Sepolia):

VRF Coordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B

LINK Token: 0x779877A7B0D9E8603169DdbD7836e478b4624789

Gas Lane (keyHash): 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae

Solidity Compiler: 0.8.19.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

⚡ How it Works

Players send ETH via enterRaffle() to participate.

The contract keeps track of participants in s_players.

After the raffle interval passes, Chainlink VRF is called in performUpkeep() to generate a random number.

A winner is selected using modulo arithmetic:

uint256 indexOfWinner = randomWords[0] % s_players.length;

Winner receives the accumulated ETH, and the raffle resets.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

📌 Notes

This contract uses custom errors for gas efficiency.

Events are emitted for all player entries and winner selections.

Chainlink VRF integration ensures fairness and transparency.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

⚠️ Security & Caveats

🚫 Learning project → Not audited, don’t use with real funds.

Contract must be added to VRF subscription as a consumer.

Tests may revert without proper environment setup.


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

📄 License

This project is licensed under the MIT License. 
 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🙌 Credits

Inspired by Cyfrin Updraft – Foundry Fundamentals (Patrick Collins).

Implementation, deployment, and documentation are my own work.

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

🧑‍💻 Author

Avishkar Chavan

📌Web3 Developer | Aspiring Smart Contract Engineer

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

📬 Contact

[X (Twitter)](https://x.com/Avishkar_666)

[LinkedIn](https://www.linkedin.com/in/avi-chavan/)
