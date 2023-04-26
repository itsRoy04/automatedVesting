const Web3 = require("web3");
const web3 = new Web3("http://188.40.131.185:22000");
const timeLockABi = require("./timeLockABI.json");
require("dotenv").config();

const contract = new web3.eth.Contract(timeLockABi, process.env.Contract);
async function transferCheck() {
  try {
    let currTime = Math.floor(Date.now() / 1000);

    console.log("Contract Address ", process.env.CONTRACT);

    let unlock_time = await contract.methods.unlockTime().call();
    let releaseTime = await contract.methods.nextReleaseSchedule().call();
    let remainingQuarter = await contract.methods.remainingQuarter().call();
    // console.log(unlock_time, currTime);
    let time = await contract.methods.time().call();

    if (Number(unlock_time) < Number(currTime)) {
      console.log("Release Time", releaseTime, currTime);
      console.log("Remaining Quarter  : ", remainingQuarter);
      if (
        Number(releaseTime) < Number(currTime) &&
        Number(remainingQuarter) != 0
      ) {
        console.log("Working");

        await signTransaction();
      } 
      else if (Number(remainingQuarter) === 0) {
        clearInterval(myInterval);
        process.exit(0);
      }

      else {
        console.log("releaseTime not reached yet");
        console.log("Remaining Quarter  : ", remainingQuarter);
      }
    }
  } catch (error) {
    console.log("Error", error);
  }
}

let myInterval = setInterval(transferCheck, 10 * 1000);

async function signTransaction() {
  try {
    console.log("hey");

    let from = await web3.utils.toChecksumAddress(process.env.PUBLIC_KEY);
    let data = contract.methods.transferVesting().encodeABI();
    let gas = await contract.methods.transferVesting().estimateGas();
    let gasPrice = await web3.eth.getGasPrice();
    let nonce = await web3.eth.getTransactionCount(from, "latest");
    console.log(process.env.PRIVATE_ADDRESS);

    const txObject = {
      from: from,
      to: process.env.CONTRACT,
      gasLimit: web3.utils.toHex(gas),
      gasPrice: gasPrice,
      nonce: nonce.toString(),
      data: data,
    };
    console.log(txObject);
    const signTx = await web3.eth.accounts.signTransaction(
      txObject,
      process.env.PRIVATE_ADDRESS
    );
    const txSend = await web3.eth.sendSignedTransaction(signTx.rawTransaction);

    let completedQuarter = await contract.methods.quarterCompleted().call();
    console.log("Completed Quarter : ", completedQuarter);
    console.log(txSend);
  } catch (error) {
    console.log("Error", error);
  }
}
