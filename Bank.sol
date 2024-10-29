// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleBank {
    struct Account {
        uint256 balance;
        bytes32 passwordHash;
    }

    mapping(address => Account) private accounts;

    modifier accountExists(address user) {
        require(accounts[user].passwordHash != 0, "Conta nao existe");
        _;
    }

    modifier correctPassword(address user, string memory password) {
        require(
            accounts[user].passwordHash == keccak256(abi.encodePacked(password)),
            "Senha incorreta"
        );
        _;
    }

    // Função para criar uma conta com uma senha
    function createAccount(string memory password) external {
        require(accounts[msg.sender].passwordHash == 0, "Conta ja existe");
        accounts[msg.sender] = Account({
            balance: 0,
            passwordHash: keccak256(abi.encodePacked(password))
        });
    }

    // Função para depositar dinheiro na conta
    function deposit() external payable accountExists(msg.sender) {
        accounts[msg.sender].balance += msg.value;
    }

    // Função para transferir dinheiro entre contas
    function transfer(
        address to,
        uint256 amount,
        string memory password
    ) external accountExists(msg.sender) correctPassword(msg.sender, password) {
        require(accounts[to].passwordHash != 0, "Conta de destino nao existe");
        require(accounts[msg.sender].balance >= amount, "Saldo insuficiente");

        accounts[msg.sender].balance -= amount;
        accounts[to].balance += amount;
    }

    // Função para sacar dinheiro
    function withdraw(uint256 amount, string memory password)
        external
        accountExists(msg.sender)
        correctPassword(msg.sender, password)
    {
        require(accounts[msg.sender].balance >= amount, "Saldo insuficiente");
        
        accounts[msg.sender].balance -= amount;
        payable(msg.sender).transfer(amount);
    }

    // Função para verificar o saldo (não exige senha para simplicidade)
    function getBalance() external view accountExists(msg.sender) returns (uint256) {
        return accounts[msg.sender].balance;
    }
}