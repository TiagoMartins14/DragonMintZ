// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {DragonMintZ} from "../src/DragonMintZ.sol";
import {DeployDragonMintZ} from "../script/DeployDragonMintZ.s.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TestableDragonMintZ} from "./TestableDragonMintZ.sol";

contract DeployDragonMintZTest is Test {
    DeployDragonMintZ deployScript;

    function setUp() external {
        deployScript = new DeployDragonMintZ();
    }

    function testDeployment() public {
        DragonMintZ dragonMintZ = deployScript.run();

        assert(address(dragonMintZ) != address(0));
    }
}

contract DragonMintZTest is Test, ERC1155 {
    TestableDragonMintZ public dragonMintZ;

    constructor() ERC1155("https://example.com/metadata/") {}

    function setUp() public {
        dragonMintZ = new TestableDragonMintZ();
    }

    function testMintRandomCharacter() public {
        address user = address(0xABCD);
        uint256 totalCharacters = dragonMintZ.TOTAL_CHARACTERS();

        for (uint256 i = 0; i < 10; i++) {
            vm.prank(user);
            dragonMintZ.mintRandomCharacter();

            bool found = false;

            for (uint256 j = 1; j <= totalCharacters; j++) {
                if (dragonMintZ.balanceOf(user, j) > i) {
                    found = true;
                    break;
                }
            }

            assertTrue(found, "User should have received a character token!");
        }
    }

    function testGetRandomCharacterId() public {
        uint256 totalCharacters = dragonMintZ.TOTAL_CHARACTERS();

        for (uint256 i = 0; i < 50000; i++) {
            vm.warp(block.timestamp + i);

            address fakeSender = address(uint160(uint256(keccak256(abi.encode(i)))));
            vm.prank(fakeSender);

            uint256 generatedRandomCharacterId = dragonMintZ.getRandomCharacterId();
            assertGe(generatedRandomCharacterId, 1, "Random character ID has to be greater than 0!");
            assertLe(
                generatedRandomCharacterId,
                totalCharacters,
                "Random character ID has to be equal or smaller than TOTAL_CHARACTERS!"
            );
        }
    }

    function testGetCharacterUri() public view {
        uint256 totalCharacters = dragonMintZ.TOTAL_CHARACTERS();

        for (uint256 i = 1; i <= totalCharacters; i++) {
            string memory expectedUri = string(
                abi.encodePacked(
                    "https://ipfs.io/ipfs/bafybeidemxyt6qodhhpimsx7jjne2cilnpdu5zieed3ntnhhwspk3arid4/",
                    Strings.toString(i),
                    ".json"
                )
            );

            assertEq(dragonMintZ.getCharacterUri(i), expectedUri, "The uri isn't matching with its expectation!");
        }
    }

    function testHasAllDragonBalls() public {
        uint256 oneStarBall = 16;
        uint256 sevenStarBall = 22;
        uint256 shenron = 15;

        vm.startPrank(msg.sender);
        for (uint256 i = oneStarBall; i <= sevenStarBall; i++) {
            assertFalse(dragonMintZ.hasAllDragonBalls(), "The user does not have all the 7 Dragon Balls!");
            dragonMintZ.mintForTest(msg.sender, i, 1);
        }
        assertTrue(dragonMintZ.hasAllDragonBalls(), "The user does have all the 7 Dragon Balls!");

        dragonMintZ.mintForTest(msg.sender, shenron, 1);
        assertFalse(dragonMintZ.hasAllDragonBalls(), "The user already has Shenron the token!");
        vm.stopPrank();
    }

    function testUnleashShenron() public {
        uint256 oneStarBall = 16;
        uint256 sevenStarBall = 22;
        uint256 shenronId = 15;

        vm.startPrank(msg.sender);
        for (uint256 i = oneStarBall; i <= sevenStarBall; i++) {
            dragonMintZ.mintForTest(msg.sender, i, 1);
        }

        assertTrue(dragonMintZ.balanceOf(msg.sender, shenronId) == 0, "The user does not have the Shenron token!");
        dragonMintZ.unleashShenron();
        assertTrue(dragonMintZ.balanceOf(msg.sender, shenronId) == 1, "The user already has the Shenron token!");
        vm.stopPrank();
    }
}
