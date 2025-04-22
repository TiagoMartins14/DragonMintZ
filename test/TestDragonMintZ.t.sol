// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {DragonMintZ} from "../src/DragonMintZ.sol";
import {DeployDragonMintZ} from "../script/DeployDragonMintZ.s.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

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

contract DragonMintZTest is Test {
    DragonMintZ dragonMintZ;

    function setUp() external {
        dragonMintZ = new DragonMintZ("https://example.com/metadata/");
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

            assertTrue(found, "User should have received a character token");
        }
    }

    function testGetRandomCharacterId() public {
        uint256 totalCharacters = dragonMintZ.TOTAL_CHARACTERS();

        for (uint256 i = 0; i < 50000; i++) {
            vm.warp(block.timestamp + i);

            address fakeSender = address(
                uint160(uint256(keccak256(abi.encode(i))))
            );
            vm.prank(fakeSender);

            uint256 generatedRandomCharacterId = dragonMintZ
                .getRandomCharacterId();
            assertGe(
                generatedRandomCharacterId,
                1,
                "Random character ID should be greater than 0!"
            );
            assertLe(
                generatedRandomCharacterId,
                totalCharacters,
                "Random character ID should be smaller than TOTAL_CHARACTERS!"
            );
        }
    }

    function testUri() public {
        uint256 totalCharacters = dragonMintZ.TOTAL_CHARACTERS();

        for (uint256 i = 1; i <= totalCharacters; i++) {
            string memory expectedUri = string(
                abi.encodePacked(
                    "https://example.com/metadata/",
                    Strings.toString(i),
                    ".json"
                )
            );

            assertEq(
                dragonMintZ.uri(i),
                expectedUri,
                "The uri isn't matching with its expectation!"
            );
        }

        vm.expectRevert();
        dragonMintZ.uri(0);

        vm.expectRevert();
        dragonMintZ.uri(totalCharacters + 1);
    }
}
