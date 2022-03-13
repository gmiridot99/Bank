const Bank = artifacts.require('Bank');
const BankUpdated = artifacts.require('BankUpdated');
const Proxy = artifacts.require('Proxy');

module.exports = async function (deployer, network, accounts) {
    //Deploy Contracts
    const bank = await Bank.new(1);
    const proxy = await Proxy.new(bank.address);
    /*
        //fool
        var proxyBank = await Bank.at(proxy.address);
    
        //try
        await proxyBank.lockDay(5, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') });
        var firstdeposit = await proxyBank.depositcheck(0);
        console.log("Before change:" + firstdeposit);
    
        //update
        const bankUpdated = await BankUpdated.new();
        proxy.upgrade(bankUpdated.address);
    
        //fool truffle again
        proxyBank = await BankUpdated.at(proxy.address);
    
        //initialize
        proxyBank.initialize(accounts[0]);
    
        //check again
        firstdeposit = await proxyBank.depositcheck(0);
        console.log("After change: " + firstdeposit);
    
        /*new deposit
        await proxyBank.lockDay(4, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') });
        var seconddeposit = await proxyBank.depositcheck(1);
        console.log("New deposit: " + seconddeposit);
    
        //timetravel
        await timeTravel(86500);
    
        //make first prewithdraw
        await proxyBank.withdrawFirst(0);
        var firstdeposit = await proxyBank.depositcheck(0);
    
        console.log("After first withdraw: " + firstdeposit);
    
        //reserve Action
        await ReserveOrderActivation(accounts[0], 0);
    
        //other time travel
        await timeTravel(86400 * 4);
    
        //reserve withdraw
        await ReserveWithdraw(accounts[0], 0);*/

}