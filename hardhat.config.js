require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
// require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.19",
  networks: {
    // matic: {
    //   url: `https://polygon-mumbai.infura.io/v3/9c0ea514ddc040059a5426506c2f12ed`,
    //   accounts:["c57828f5b54c5f3fa21619871ff454567adf25703e74da0038a3b3c02c3615d5"]
    // },
    hedera: {
      url: `https://testnet.hashio.io/api`,
      accounts:["0x6644b6b93f8a1152937ad11d9a7951ec0760d0854b16e892423965241bda2401"]
    }
  }
};