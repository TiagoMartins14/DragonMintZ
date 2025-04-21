// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
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
        uint256 characterId = getRandomCharacterId();
        _mint(msg.sender, characterId, 1, "");
        string memory characterURI = uri(characterId);
        emit CharacterMinted(msg.sender, characterId, characterURI);
    }

    /// @notice Helper function to get a random character
    function getRandomCharacterId() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        msg.sender,
                        block.prevrandao
                    )
                )
            ) % TOTAL_CHARACTERS;
    }

    /// @notice Returns full URI for token metadata
    function uri(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < TOTAL_CHARACTERS, "Invalid character ID");
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(tokenId), ".json")
            );
    }
}
