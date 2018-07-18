const NETWORK = 3;
const config = require('../config');
const Tx = require('ethereumjs-tx');
const Web3 = require('web3');
const web3 = new Web3(config.url);

// const borrowLoanWei = 500000000000000000;
// const borrowLoanBN = web3.utils.toBN(borrowLoanWei);
// const borrowLoanEther = web3.utils.fromWei(borrowLoanBN, 'ether');
// setup abi
const MicroFinanceJson = require('../contract/build/contracts/MicroFinance.json');
const MicroFinanceSolc = new web3.eth.Contract(MicroFinanceJson.abi, MicroFinanceJson.networks[NETWORK].address);
let MicroFinanceMethodAbi;

/** raw data which will be send */
let data = {};

/** sign transaction  */
Promise.resolve().then(() => {
    MicroFinanceMethodAbi = MicroFinanceSolc.methods.createLoan(0.5).encodeABI();
    console.log('Borrow: 0.5');
})
.then(() => {
    // take gasPrice
    return web3.eth.getGasPrice().then((_) => {
        data.gasPrice = web3.utils.toHex(_);
    });
})
.then(() => {
    // take nonce
    return web3.eth.getTransactionCount(config.account.address).then((nonce) => {
        data.nonce = nonce;
        console.log(`transactionCount : ${nonce}`);
    });
})
.then(() => {
    // take gasLimit
    return web3.eth.estimateGas({
        to: MicroFinanceJson.networks[NETWORK].address,
        data: MicroFinanceMethodAbi
    }).then((gasLimit) => {
        data.gasLimit = web3.utils.toHex(gasLimit)
        console.log(`gasLimit: ${gasLimit}`);
    });
})
.then(() => {
    let rawTx = {
        nonce: data.nonce,
        gasPrice: data.gasPrice,
        gasLimit: data.gasLimit,
        to: MicroFinanceJson.networks[NETWORK].address,
        data: MicroFinanceMethodAbi
    }

    const tx = new Tx(rawTx);
    ts.sign(new Buffer(config.account.privateKey), 'hex');
    const serializedTx = tx.serialize();

    /** show all information of transaction
     * include: blockhash, blocknumber, from, gasUsed, status, 
     * transaction Hash
     */
    return web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex')).on('transactionHash', function(hash) {
        console.log("hash:", hash);
      }).on('receipt', function(hash) {
        console.log("receipt:", hash);
      }).catch(console.log);
}).catch(console.log);