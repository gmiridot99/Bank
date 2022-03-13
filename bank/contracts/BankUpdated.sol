// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.5;
pragma experimental ABIEncoderV2;

import "./Storage.sol";

// not using msg.value
contract BankUpdated is Storage{

    constructor() public{
        initialize(msg.sender);
    }

    function initialize(address _owner) public{
        require(!_initialized);
        owner = _owner;
        _initialized = true;
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function changeFee(uint256 newfee) public onlyOwner{
        _uintStorage["fee"] = newfee;
    }

    function revenueWithdraw() public onlyOwner{
        payable(owner).transfer(balances[owner]);
    }
    event locksuccess(uint256 amount, uint256 timeLock, address client);
    event withdrawsuccess(uint256 amount, address client);
    event withdrawReservesuccess(uint256 amount, address client, address reserveClient);

    function contractBalance() public view returns(uint256){return address(this).balance;}

    function checktimestamp() public view returns(uint256){
        return block.timestamp;
    }
    
    function depositcheck(uint256 order) public view returns(timeLock memory){
       require(order <= locking[msg.sender].length, "Nope"); //onlyOwnlocking but there is the mapping, it is "Private"
       return(locking[msg.sender][order]);
    }

    function lockDay(uint256 _timelock, uint256 _firstWithdraw, uint256 _nextWithdraw, address _reserveAccount /*amount?*/) public payable { //add fee/cost
        uint256 endlock;
        uint256 firstWithdraw;
        uint256 amount = msg.value; // -fee
        uint256 fee = (amount * _uintStorage["fee"])/ 100;
        uint256 tot = amount - fee;
        endlock = block.timestamp + (_timelock * 1 days);
        firstWithdraw = block.timestamp + (_firstWithdraw * 1 days);

        timeLock memory newlock = timeLock(amount - fee, block.timestamp, endlock, firstWithdraw, _nextWithdraw, 0, _reserveAccount, false);

        locking[msg.sender].push(newlock);
        balances[msg.sender] = balances[msg.sender] + tot;
        balances[owner] = balances[owner] + fee;
        emit locksuccess(msg.value, endlock, msg.sender);
    }
    function lockWeeks(uint256 _timelock, uint256 _firstWithdraw, uint256 _nextWithdraw, address _reserveAccount  /*amount?*/) public payable { //add fee/cost
        uint256 endlock;
        uint256 firstWithdraw;
        uint256 amount = msg.value; // -fee
        uint256 fee = (amount * _uintStorage["fee"])/ 100;
        endlock = block.timestamp + (_timelock * 1 weeks);
        firstWithdraw = block.timestamp + (_firstWithdraw * 1 weeks);

        timeLock memory newlock = timeLock(amount - fee, block.timestamp, endlock, firstWithdraw, _nextWithdraw, 0, _reserveAccount, false);

        locking[msg.sender].push(newlock);
        balances[msg.sender] = balances[msg.sender] + (amount - fee);
        balances[owner] = balances[owner] + fee;
        emit locksuccess(msg.value, endlock, msg.sender);
    }

    function lockMonths(uint256 _timelock, uint256 _firstWithdraw, uint256 _nextWithdraw, address _reserveAccount /*amount?*/) public payable { //add fee/cost
        uint256 endlock;
        uint256 firstWithdraw;
        uint256 amount = msg.value; // -fee
        uint256 fee = (amount * _uintStorage["fee"])/ 100;
        endlock = block.timestamp + (_timelock * (30* 1 weeks));
        firstWithdraw = block.timestamp + (_firstWithdraw * (30* 1 weeks));

        timeLock memory newlock = timeLock(amount - fee, block.timestamp, endlock, firstWithdraw, _nextWithdraw, 0, _reserveAccount, false);

        locking[msg.sender].push(newlock);
        balances[msg.sender] = balances[msg.sender] + (amount - fee);
        balances[owner] = balances[owner] + fee;
        emit locksuccess(msg.value, endlock, msg.sender);
    }

    function withdraw(uint256 order) public { 
        require(block.timestamp >= locking[msg.sender][order].timerEnd, "Not expired yet");
        require(locking[msg.sender][order].reserveActive == false, "Reserve withdraw activated");
        uint256 amount = locking[msg.sender][order].amount;
        locking[msg.sender][order].amount = 0;
        payable(msg.sender).transfer(amount);
        balances[msg.sender] = balances[msg.sender] - amount;
        emit withdrawsuccess(amount, msg.sender);
        {
            for(uint256 i = order; i < locking[msg.sender].length - 1; i++){
            locking[msg.sender][i] = locking[msg.sender][i+1]; 
            }
            locking[msg.sender].pop();
        }
    }

    function withdrawFirst(uint256 order) public{

        require(block.timestamp < locking[msg.sender][order].timerEnd, "Nope, you can withdraw all");
        
        uint256 Timerstats = locking[msg.sender][order].timerEnd - locking[msg.sender][order].timerStart;
        uint256 amount = (locking[msg.sender][order].amount *1)/ 100;

        require(block.timestamp > locking[msg.sender][order].timeFirstWithdraw, "Can't start to withdraw yet");
        require(block.timestamp - locking[msg.sender][order].lastWithdraw > (Timerstats / locking[msg.sender][order].timeFirstWithdraw), "Already withdraw this month");

        locking[msg.sender][order].lastWithdraw = block.timestamp;
        locking[msg.sender][order].amount = locking[msg.sender][order].amount - amount;
        payable(msg.sender).transfer(amount);
        balances[msg.sender] = balances[msg.sender] - amount;
    }

    function ReserveOrderActivation(address client, uint256 order) public{
        require(client != msg.sender, "You can't be your own client");
        require(locking[client][order].reserveAccount == msg.sender, "You are not allowed");
        require(locking[client][order].reserveActive != true, "Reserve withdraw  already activated");
        require(block.timestamp < locking[client][order].timerEnd, "Already expired");
        locking[client][order].reserveActive = true;
    }

    function ReserveWithdraw(address client, uint256 order) public{
        require(client != msg.sender, "You can't be your own client");
        require(locking[client][order].reserveAccount == msg.sender, "You are not allowed");
        require(locking[client][order].reserveActive == true, "Reserve withdraw not-activated");
        require(block.timestamp >= locking[client][order].timerEnd, "Not yet expired");

        uint256 amount = locking[client][order].amount;
        locking[client][order].amount = 0;
        payable(msg.sender).transfer(amount);
        balances[client] = balances[client] - amount;
        emit withdrawReservesuccess(amount, client, msg.sender);
        {
            for(uint256 i = order; i < locking[client].length - 1; i++){
            locking[client][i] = locking[client][i+1]; 
            }
            locking[client].pop();
        }
    }
    
    //function allowance + use amount and not msg.value
}
