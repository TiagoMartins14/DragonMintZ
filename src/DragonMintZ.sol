// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/Script.sol";

contract DragonMintZ is ERC1155 {
    uint256 public constant TOTAL_CHARACTERS = 22;
    string public baseURI;

    constructor()
        ERC1155(
            "https://ipfs.io/ipfs/bafybeidemxyt6qodhhpimsx7jjne2cilnpdu5zieed3ntnhhwspk3arid4/"
        )
    {}

    event CharacterMinted(
        address indexed user,
        uint256 characterId,
        string uri
    );

    /// @notice Mint a random DBZ character NFT to the caller
    function mintRandomCharacter() public {
        uint256 characterId = 15;
        while (characterId == 15) {
            characterId = getRandomCharacterId();
        }
        _mint(msg.sender, characterId, 1, "");
        string memory characterURI = getCharacterUri(characterId);
        emit CharacterMinted(msg.sender, characterId, characterURI);
    }

    /// @notice Helper function to get a random character
    function getRandomCharacterId() public view returns (uint256) {
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        block.prevrandao
                    )
                )
            ) % TOTAL_CHARACTERS) + 1;
    }

    /// @notice Returns full URI for token metadata
    function getCharacterUri(uint256 tokenId) public view returns (string memory) {
        require(tokenId <= TOTAL_CHARACTERS, "Invalid character ID");
        require(tokenId > 0, "Invalid character ID");
        return
            string(
                abi.encodePacked(uri(tokenId), Strings.toString(tokenId), ".json")
            );
    }

    function hasAllDragonBalls() public view returns (bool) {
        uint256 oneStarBall = 16;
        uint256 sevenStarBall = 22;
        uint256 shenron = 15;
        bool hasSevenDragonBalls = false;

        if (balanceOf(msg.sender, shenron) > 0) {
            return false;
        }

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

    function unleashShenron() public {
        uint256 shenronId = 15;

        _mint(msg.sender, shenronId, 1, "");
        string memory characterURI = uri(shenronId);
        emit CharacterMinted(msg.sender, shenronId, characterURI);
    }
}
