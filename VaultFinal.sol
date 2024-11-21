// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PublicVault {

    bytes32 passwordHash;
    address public owner;

    // Events
    event DepositMade(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);
    event DepositReclaimed(address indexed owner, uint256 amount);

    // Modificadores
    // Executa apenas se o dono chamar a funcao
    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono pode executar esta operacao");
        _;
    }

    // Executa apenas se tem valor no contrato 
    modifier depositExists() {
        require(address(this).balance > 0, "Deposito nao existe");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(bytes32 password) external payable onlyOwner() {
        require(msg.value > 0, "O valor do deposito deve ser maior que zero");
        passwordHash = password;
        emit DepositMade(msg.sender, msg.value);
    }

    function resetPassword(bytes32 newPasswordHash) external onlyOwner {
        passwordHash = newPasswordHash;
    }

    function withdraw(string memory password) external depositExists() {
        require(passwordHash == keccak256(abi.encodePacked(password)), "Senha incorreta");
        passwordHash = bytes32(0);
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(address(this).balance);
        emit Withdrawal(msg.sender, balance);
    }

    function reclaimDeposit() external depositExists() onlyOwner() {
        passwordHash = bytes32(0);
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
        emit DepositReclaimed(msg.sender, balance);
    }

    function showBalance() view external returns(uint256){
        return(address(this).balance); 
    }
}