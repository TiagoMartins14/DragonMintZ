// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {DragonMintZ} from "../src/DragonMintZ.sol";

contract TestableDragonMintZ is DragonMintZ {
    function mintForTest(address to, uint256 id, uint256 amount) public {
        _mint(to, id, amount, "");
    }
}
