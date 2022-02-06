const { ethers } = require("ethers");

const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('MyBoldNFT');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();

    console.log('NFT Contract deployed to: ', nftContract.address);

    let txn = await nftContract.mintABoldNFT();
    await txn.wait();

    txn = await nftContract.mintABoldNFT();
    await txn.wait();


}

const runMain = async () => {
    try {
        await main();
        process.exit(0);

    } catch (e) {
        console.log(e);
        process.exit(1);
    }
}

runMain();