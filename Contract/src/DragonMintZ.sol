// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {console} from "forge-std/Script.sol";

contract DragonMintZ is ERC1155 {
    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 private constant TOTAL_CHARACTERS = 22;
    uint256 private constant ONE_STAR_BALL = 16;
    uint256 private constant SEVEN_STAR_BALL = 22;
    uint256 private constant SHENRON_ID = 15;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event CharacterMinted(address indexed user, uint256 characterId, string uri);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor() ERC1155("https://ipfs.io/ipfs/bafybeidemxyt6qodhhpimsx7jjne2cilnpdu5zieed3ntnhhwspk3arid4/") {}


    /**
     * @notice Mints a random DBZ character NFT to the caller.
     */
    function mintRandomCharacter() public {
        uint256 characterId = getRandomCharacterId();

        _mint(msg.sender, characterId, 1, "");
        string memory characterURI = getCharacterUri(characterId);
        emit CharacterMinted(msg.sender, characterId, characterURI);
    }

    /**
     * @notice Helper function to get a random character.
     * @dev Shenron is a special character that cannot be minted this way. The user only gets the option to mint it the moment they collect all the 7 Dragon Balls tokens.
     * @return A random character.
     */
    function getRandomCharacterId() public view returns (uint256) {
        uint256 getRandomCharacter = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.prevrandao)))
            % (TOTAL_CHARACTERS - 1) + 1;
        if (getRandomCharacter == 15) {
            getRandomCharacter = 22;
        }
        return getRandomCharacter;
    }

    /**
     * @notice Gets full URI for token metadata.
     * @param tokenId The token id to get the URI from.
     * @return Full URI for token metadata.
     */
    function getCharacterUri(uint256 tokenId) public view returns (string memory) {
        return string(abi.encodePacked(uri(tokenId), Strings.toString(tokenId), ".json"));
    }

    /**
     * @notice Checks if the caller has all 7 Dragon Balls tokens (16, 17, 18, 19 ,20, 21, 22).
     * @return True if it has all 7 Dragon Balls tokens.
     */
    function hasAllDragonBalls() public view returns (bool) {
        bool hasSevenDragonBalls = false;

        for (uint256 i = ONE_STAR_BALL; i <= SEVEN_STAR_BALL; i++) {
            if (balanceOf(msg.sender, i) > 0) {
                hasSevenDragonBalls = true;
            } else {
                hasSevenDragonBalls = false;
                break;
            }
        }
        return hasSevenDragonBalls;
    }

    /**
     * @notice Mints Shenron token (15)
     * @dev The user can only mint the Shenron token the moment he/she collects all 7 dragon balls. If he doesn't accept to mint it, each time another Dragon Ball is collected, the option to mint the Shenron token is presented again to the user.
     */
    function unleashShenron() private {
        require(balanceOf(msg.sender, SHENRON_ID) < 1, "You already summoned Shenron!");
        require(hasAllDragonBalls(), "You need to have all 7 Dragon Balls to summon Shenron.");
        _mint(msg.sender, SHENRON_ID, 1, "");
        string memory characterURI = uri(SHENRON_ID);
        emit CharacterMinted(msg.sender, SHENRON_ID, characterURI);
    }
}
