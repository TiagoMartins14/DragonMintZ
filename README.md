# <div align="center">🐉 DragonMintZ</div>
<p align="center">A roulette-style NFT minting dApp where Dragon Ball Z fans can collect characters and items — and summon Shenron.</p>
<p align="center">https://dragonmintz.netlify.app</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b5aa274f-1637-456f-a76c-4a9d3a073cd7" alt="banner" />
</p>


## Overview

DragonMintZ is a Web3 application that lets users mint NFT representations of legendary DBZ characters and the iconic 7 Dragon Balls using a random minting mechanism powered by the Ethereum Virtual Machine (EVM).

The project utilizes:
- **Foundry** for contract development, testing, and deployment
- **ERC1155** for flexible token standard
- **IPFS (via Pinata)** for hosting token metadata and images

## Technical Decisions

- **Why ERC1155?**  
  ERC1155 was chosen over ERC721 to allow multiple instances of the same token. This means that users can mint and own the same DBZ character or Dragon Ball token without each instance being entirely unique. It’s ideal for collectible-based applications where token types are limited but quantity is not.

- **Efficient IPFS Structure**  
  All token metadata JSON files and associated images are pinned under a single IPFS CID. This makes it possible to construct token URIs by simply swapping the filename at the end of a common base URL. This approach reduces complexity in both the smart contract and frontend logic, while also improving maintainability.

- **Conditional Minting for Special Token**  
  A special token—**Shenron**—can only be minted by users who meet a specific condition: owning all **7 Dragon Ball tokens**. To enforce this, the minting function includes strict `require` statements that verify ownership before allowing the mint. This prevents users from bypassing the intended gameplay logic and ensures that Shenron remains a true achievement-based reward.

## Token Breakdown

- 🎴 **15 Characters** – Each minted randomly.
- 🟠 **7 Dragon Balls** – Collectible, and key to unlocking Shenron.
- 🐉 **Shenron** – A special NFT that becomes available only when the user holds **all 7 Dragon Balls**.

> Shenron can only be minted once **per wallet** and only the **after** all Dragon Balls are collected.

![Image](https://github.com/user-attachments/assets/8757ca32-88f9-4d6e-b2e8-1a634d1296c8)

## Randomness Mechanism

The character or item minted is determined by a pseudo-random algorithm:

1. Concatenates the caller’s address, the current timestamp, and previous block hash.
2. Applies a keccak256 hash to the data.
3. Reduces the result using modulus to fit the available token ID range.

> ⚠️ This randomness is **not cryptographically secure**. It’s sufficient for fun minting, but susceptible to manipulation in high-stakes settings. For real randomness, services like Chainlink VRF are recommended.

## Contracts & Deployment

The smart contracts follow the **ERC1155** standard for multi-token minting (Shenron logic is implemented via internal state checks during minting).

> Contract deployed with [Foundry](https://getfoundry.sh/) to Sepolia Testnet ([Address](https://sepolia.etherscan.io/address/0x0aAE778c2083b2111eDdd5bf44d3b41947d43F08))
> 
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
```

Once done, open your browser and navigate to https://localhost:3000 to access the app.

## Tips & Testing

### Interacting with the Docker Container

You can interact with the container on a separate terminal window via:
```bash
docker exec -it dragonmintz bash
```

### Running Smart Contract Tests

Navigate to the contract directory and run:
```bash
cd Contract
forge test
```

<p align="center">
  <img src="https://github.com/user-attachments/assets/ff1b47eb-05ba-4630-8edd-8708ba5365a7" alt="banner" />
</p>

## Upcoming Features

- Display a list of NFTs minted by the user
- Enable trading functionality between user accounts