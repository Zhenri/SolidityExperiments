// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract PublicVault {
    struct Deposit {
        uint256 amount;
        bytes32 passwordHash;
        uint256 depositTime;
        bool withdrawn;
    }

    address public owner;
    uint256 public expirationTime = 2 days; // Tempo padrão para retirada (2 dias)
    mapping(address => Deposit) private deposits;

    modifier onlyOwner() {
        require(msg.sender == owner, "Apenas o dono pode executar esta operacao");
        _;
    }

    modifier depositExists(address depositor) {
        require(deposits[depositor].amount > 0, "Deposito nao existe");
        _;
    }

    modifier notWithdrawn(address depositor) {
        require(!deposits[depositor].withdrawn, "Deposito ja retirado");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Função para realizar um depósito com senha
    function deposit(string memory password) external payable onlyOwner() {
        require(msg.value > 0, "O valor do deposito deve ser maior que zero");
        require(deposits[msg.sender].amount == 0 || deposits[msg.sender].withdrawn, "Voce ja possui um deposito nao retirado");

        deposits[msg.sender] = Deposit({
            amount: msg.value,
            passwordHash: keccak256(abi.encodePacked(password)),
            depositTime: block.timestamp,
            withdrawn: false
        });
    }

    // Função para qualquer pessoa sacar o valor com a senha correta
    function withdraw(string memory password) external depositExists(owner) {
        Deposit storage dep = deposits[owner];
        require(dep.passwordHash == keccak256(abi.encodePacked(password)), "Senha incorreta");

        dep.withdrawn = true;
        uint256 amountToWithdraw = dep.amount;
        dep.amount = 0;
        payable(msg.sender).transfer(amountToWithdraw);
    }

    // Função para o depositante recuperar os fundos após o prazo de expiração, caso ninguém tenha sacado
    function reclaimDeposit() external depositExists(msg.sender) notWithdrawn(msg.sender) {
        Deposit storage dep = deposits[msg.sender];
        require(block.timestamp >= dep.depositTime + expirationTime, "Deposito ainda nao expirou");

        dep.withdrawn = true;
        uint256 amountToReclaim = dep.amount;
        dep.amount = 0;
        payable(msg.sender).transfer(amountToReclaim);
    }

    // Função para o dono do contrato ajustar o tempo de expiração (em segundos)
    function setExpirationTime(uint256 newExpirationTime) external onlyOwner {
        expirationTime = newExpirationTime;
    }

    // Função para consultar o valor depositado (não exige senha para simplicidade)
    function getDepositInfo() external view returns (uint256, bool) {
        Deposit storage dep = deposits[owner];
        return (dep.amount, dep.withdrawn);
    }
}