// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Encryption{
    bytes32 hashedPassword;
    function encrypt(string memory password) external {
        hashedPassword = keccak256(abi.encodePacked(password));
    }

    function showHashedPassword() view external returns (bytes32){
        return hashedPassword;
    }

    function isEqualToString(bytes32 input)view external returns (bool){
        return(input == hashedPassword);
    }
}