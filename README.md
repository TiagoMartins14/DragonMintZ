# <div align="center">🐉 DragonMintZ</div>
<p align="center">A roulette-style NFT minting dApp where Dragon Ball Z fans can collect characters and items — and summon Shenron.</p>
<p align="center">https://dragonmintz.netlify.app</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b5aa274f-1637-456f-a76c-4a9d3a073cd7" alt="banner" />
</p>


## Overview

DragonMintZ is a Web3 application that lets users mint NFT representations of legendary DBZ characters and the iconic 7 Dragon Balls using a random minting mechanism powered by the Ethereum Virtual Machine (EVM).

The project utilizes:
- **Foundry** for contract development
- **ERC1155** for flexible token standard
- **IPFS (via Pinata)** to host character metadata and images

## Token Breakdown

- 🎴 **15 Characters** – Each minted randomly.
- 🟠 **7 Dragon Balls** – Collectible, and key to unlocking Shenron.
- 🐉 **Shenron** – A special NFT that becomes available only when the user holds **all 7 Dragon Balls**.

> Shenron can only be minted once **per wallet** and only the **after** all Dragon Balls are collected.

![Image](https://github.com/user-attachments/assets/8757ca32-88f9-4d6e-b2e8-1a634d1296c8)

## 🎲 Randomness Mechanism

The character or item minted is determined by a pseudo-random algorithm:

1. Concatenates the caller’s address, the current timestamp, and previous block hash.
2. Applies a keccak256 hash to the data.
3. Reduces the result using modulus to fit the available token ID range.

> ⚠️ This randomness is **not cryptographically secure**. It’s sufficient for fun minting, but susceptible to manipulation in high-stakes settings. For real randomness, services like Chainlink VRF are recommended.

## Contracts & Deployment

The smart contracts follow the **ERC1155** standard for multi-token minting (Shenron logic is implemented via internal state checks during minting).

> Contracts deployed to Avalanche Fuji Testnet
> Metadata and token art stored on IPFS via [Pinata](https://pinata.cloud)

## Getting Started

### Prerequisites

To build and run the app locally:
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [Make](https://www.gnu.org/software/make/)

### Installation

```bash
git clone https://github.com/TiagoMartins14/DragonMintZ.git
cd DragonMintZ
make
