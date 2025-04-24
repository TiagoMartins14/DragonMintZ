# DragonMintZ
A project about a minting Dragon Ball Z characters/items in a roulette type way

## 🧠 "Randomness":
This contract generates a "random" character ID like this:

1. Combine the current timestamp, caller address, and randomness from the previous block.

2. Hash that data to get a number that appears random.

3. Reduce it to the valid character ID range using modulus.

## ⚠️ Important Note on Security:
This kind of randomness is not secure for high-stakes randomness (e.g., lotteries or games with real value), because miners or other actors might influence block.timestamp or predict msg.sender. For secure randomness, you'd want something like Chainlink VRF.

Pre-requesite: docker

clone project

inside the project folder run: make