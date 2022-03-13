const Bank = artifacts.require("Bank")
const Proxy = artifacts.require("Proxy")
//const truffleAssert = require('truffle-assertions');

const jsonrpc = '2.0'
const id = 0
const send = (method, params = []) =>
    web3.currentProvider.send({ id, jsonrpc, method, params })
const timeTravel = async seconds => {
    await send('evm_increaseTime', [seconds])
    await send('evm_mine')
}
module.exports = timeTravel

contract("Bank", accounts => {

    it("Should lock 3 times: 1 minutes, 2 minutes, 5 minutes and errore with time > 3", async () => {
        const bank = await Bank.deployed()
        const proxy = await Proxy.deployed()

        var proxyBank = await Bank.at(proxy.address);

        await truffleAssert(proxyBank.lockDay(1, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') }))
        await truffleAssert(proxyBank.lockDay(2, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') }))
        await truffleAssert(proxyBank.lockDay(5, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') }))
        await truffleAssert.reverts(proxyBank.lockDay(5, 5, 1, 1))
    })
    /*it("should withdraw the first lock", async () => {
        let bank = await bank.deployed()
        await truffleAssert(bank.lockDay(1, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') }))
        await timeTravel(86500) //???
        await truffleAssert(bank.withdraw(0))
    })
    it("should withdraw the first lock", async () => {
        let bank = await bank.deployed()
        await bank.lockDay(1, 1, 1, accounts[1], { value: web3.utils.toWei('0.2', 'ether') })
        await timeTravel(60)
        await truffleAssert(bank.withdraw(0))
    })
    it("Should throw an error if ETH balance is not > limit BUY order value", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await dex.depositEth({ value: 5 })

        await truffleAssert.reverts(
            dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        await dex.depositEth({ value: 3000 })
        await truffleAssert.reverts(
            dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    })

    it("should throw an error if token balance is too low when creating SELL limit order", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await dex.depositEth({ value: 3000 })
        await truffleAssert.reverts(
            dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
        await link.approve(dex.address, 500);
        await dex.addToken(web3.utils.fromUtf8("LINK"), link.address, { from: accounts[0] });
        await dex.deposit(10, web3.utils.fromUtf8("LINK"));
        await truffleAssert.passes(
            dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 10, 1)
        )
    })

    it("The BUY order book should be ordered on price from highest to lowest starting at index 0", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()
        await link.approve(dex.address, 500);
        await dex.depositEth({ value: 3000 })
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(0, web3.utils.fromUtf8("LINK"), 1, 200)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 0);
        assert(orderbook.length > 0);
        console.log(orderbook);
        for (let i = 0; i < orderbook.length - 1; i++) {
            assert(orderbook[i].price >= orderbook[i + 1].price, "not in the right order in sell book")
        }
    })

    it("The SELL order book should be ordered on price from lowest to highest starting at index 0", async () => {
        let dex = await Dex.deployed()
        let link = await Link.deployed()

        await link.approve(dex.address, 500);
        await dex.depositEth({ value: 3000 })
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 300)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 100)
        await dex.createLimitOrder(1, web3.utils.fromUtf8("LINK"), 1, 200)

        let orderbook = await dex.getOrderBook(web3.utils.fromUtf8("LINK"), 1);
        assert(orderbook.length > 0);

        for (let i = 0; i < orderbook.length - 1; i++) {
            assert(orderbook[i].price <= orderbook[i + 1].price, "not in the right order in sell book")
        }
    })*/
})