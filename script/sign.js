require('dotenv').config()
const hre = require("hardhat");

async function main() {
    const projectId = process.env.PROJECT_ID
    const provider = new hre.ethers.providers.InfuraProvider(null, projectId)
    let PK = process.env.PRIVATE_KEY

    const signer = new ethers.Wallet(PK, provider)
    console.log(await signer.signMessage(ethers.utils.arrayify('0x3cd65f6089844a3c6409b0acc491ca0071a5672c2ab2a071f197011e0fc66b6a'))) // riddle_3_hash
    // console.log(await signer.signMessage(ethers.utils.arrayify('0x9c611b41c1f90946c2b6ddd04d716f6ec349ac4b4f99612c3e629db39502b941'))) // hashed abi.encodePacked('The Merge')
}

main();