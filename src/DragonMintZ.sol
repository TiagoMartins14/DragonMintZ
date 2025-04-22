// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/Script.sol";

contract DragonMintZ is ERC1155 {
    uint256 public constant TOTAL_CHARACTERS = 22;
    string public baseURI;

    constructor(string memory _baseURI) ERC1155("") {
        baseURI = _baseURI;
    }

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
        string memory characterURI = uri(characterId);
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
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(tokenId <= TOTAL_CHARACTERS, "Invalid character ID");
        require(tokenId > 0, "Invalid character ID");
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")
            );
    }

    function getBalanceOfToken(uint256 tokenId) public view returns (uint256) {
        return balanceOf(msg.sender, tokenId);
    }
}
