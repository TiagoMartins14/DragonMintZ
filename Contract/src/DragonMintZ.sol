// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/Script.sol";

contract DragonMintZ is ERC1155 {
    uint256 public constant TOTAL_CHARACTERS = 22;

    constructor() ERC1155("https://ipfs.io/ipfs/bafybeidemxyt6qodhhpimsx7jjne2cilnpdu5zieed3ntnhhwspk3arid4/") {}

    event CharacterMinted(address indexed user, uint256 characterId, string uri);

    /// Mints a random DBZ character NFT to the caller
    function mintRandomCharacter() public {
        uint256 characterId = getRandomCharacterId();

        _mint(msg.sender, characterId, 1, "");
        string memory characterURI = getCharacterUri(characterId);
        emit CharacterMinted(msg.sender, characterId, characterURI);
    }

    // Helper function to get a random character
    function getRandomCharacterId() public view returns (uint256) {
        uint256 getRandomCharacter = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)))
            % (TOTAL_CHARACTERS - 1) + 1;
        if (getRandomCharacter == 15) {
            getRandomCharacter = 22;
        }
        return getRandomCharacter;
    }

    // Returns full URI for token metadata
    function getCharacterUri(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(uri(tokenId), Strings.toString(tokenId), ".json"));
    }

    // Checks if the caller has all 7 Dragon Balls
    function hasAllDragonBalls() public view returns (bool) {
        uint256 oneStarBall = 16;
        uint256 sevenStarBall = 22;
        bool hasSevenDragonBalls = false;

        for (uint256 i = oneStarBall; i <= sevenStarBall; i++) {
            if (balanceOf(msg.sender, i) > 0) {
                hasSevenDragonBalls = true;
            } else {
                hasSevenDragonBalls = false;
                break;
            }
        }
        return hasSevenDragonBalls;
    }

    // Mints Shenron token
    function unleashShenron() public {
        uint256 shenronId = 15;

        require(balanceOf(msg.sender, shenronId) < 1, "You already summoned Shenron!");
        require(hasAllDragonBalls(), "You need to have all 7 Dragon Balls to summon Shenron.");
        _mint(msg.sender, shenronId, 1, "");
        string memory characterURI = uri(shenronId);
        emit CharacterMinted(msg.sender, shenronId, characterURI);
    }
}
