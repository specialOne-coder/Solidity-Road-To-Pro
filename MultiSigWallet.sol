// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

//@title MultiSigWallet
//@version 0.1
//@author Ferdinand
//@notice submit transaction, approve and revoke approval of pending transactions.
//Anyone can execute transaction after  enough approvals.
contract MultiSigWallet {
    event Deposit(address indexed sender, uint256 amount, uint256 balance); // deposit event
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    ); // submit transaction event
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex); // confirm transaction event
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex); // revoke confirmation event
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex); // execute transaction event

    address[] public owners; // owners of the wallet
    mapping(address => bool) public isOwner; // is owner of the wallet
    uint256 public numConfirmationsRequired; // number of confirmations required to execute transaction

    struct Transaction {
        address to; // address of the receiver
        uint256 value; // value of the transaction
        bytes data; // data of the transaction
        bool executed; // is transaction executed
        uint256 numConfirmations; // number of confirmations
    }

    mapping(uint256 => mapping(address => bool)) public isConfirmed; // is transaction confirmed by owner

    Transaction[] public transactions; // transactions

    modifier onlyOwner() {
        // modifier (only owner can call function)
        require(isOwner[msg.sender], "not Owner");
        _;
    }

    modifier txExists(uint256 txIndex) {
        // modifier (transaction exists)
        require(txIndex < transactions.length, "transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 txIndex) {
        // modifier (transaction not executed)
        require(
            !transactions[txIndex].executed,
            "transaction already executed"
        );
        _;
    }

    modifier notConfirmed(uint256 txIndex) {
        // modifier (transaction not confirmed)
        require(
            !isConfirmed[txIndex][msg.sender],
            "transaction already confirmed"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequired) { // multisig wallet constructor
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );
        uint length = _owners.length;
        for(uint i = 0; i < length; ++i){
            address owner = _owners[i];
            require(owner != address(0), "invalid owner");
            require(!isOwner[owner], "owner not unique");

            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    ///@notice create transaction
    ///@param to is addres that receive transaction, _value is value on tx ...
    function submitTransactions(address to, uint _value, bytes memory data) pulbic onlyOwner{
        uint txIndex = transactions.length;

        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed: false,
            numConfirmations: 0
        }));

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

}
