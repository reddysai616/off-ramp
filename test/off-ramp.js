const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UserDataStorage Contract", function () {
  let UserDataStorage;
  let userDataStorage;

  beforeEach(async function () {
    UserDataStorage = await ethers.getContractFactory("UserDataStorage"); // Replace with the actual contract name
    userDataStorage = await UserDataStorage.deploy();
    // await userDataStorage.deployed();
  });

  // it("should allow the contract to call withdraw", async function () {
  //   // Perform a withdrawal
  //   const userId = "testUserId";
  //   const walletAddress = ethers.Wallet.createRandom().address;
  //   const paymentMode = "PaymentMode";
  //   const totalWithdrawalBalance = 100;
  
  //   // Debugging: Log the input values
  //   console.log("userId:", userId);
  //   console.log("walletAddress:", walletAddress);
  //   console.log("paymentMode:", paymentMode);
  //   console.log("totalWithdrawalBalance:", totalWithdrawalBalance);
  
  //   await userDataStorage.withdraw(userId, walletAddress, paymentMode, totalWithdrawalBalance);
  
  //   // Check if the withdrawal data was recorded correctly
  //   const userTransactions = await userDataStorage.getTransactionsForUser(userId, walletAddress);
  //   console.log("userTransactions:", userTransactions); // Debugging: Log userTransactions
  
  //   // Debugging: Log the properties of the first transaction
  //   if (userTransactions.length > 0) {
  //     const transaction = userTransactions[0];
  //     console.log("transaction.userId:", transaction.userId);
  //     console.log("transaction.walletAddress:", transaction.walletAddress);
  //     // Add more debug logs for other properties
  //   }
  //   // 8807802223
    
  
  //   // Assert the actual result against the expected result
  //   expect(userTransactions.length).to.equal(1);
  //   // expect(userTransactions.length).to.equal(2);




  //   // Add more assertions as needed
  // });






  it("should allow the contract to call fiat", async function () {
    const userId = "testUserId";
    const walletAddress = ethers.Wallet.createRandom().address;
    const remainingWithdrawalBalance = 100;
    const paymentMode = "Fiat";
    const withdrawalAmount = 50;
    const totalWithdrawalBalance = remainingWithdrawalBalance + withdrawalAmount;
        // Debugging: Log the input values
    console.log("userId:", userId);
    console.log("walletAddress:", walletAddress);
    console.log("paymentMode:", paymentMode);
    console.log("totalWithdrawalBalance:", totalWithdrawalBalance);
    console.log("withdrawalAmount:", withdrawalAmount);
    console.log("remainingWithdrawalBalance:", remainingWithdrawalBalance);



    await userDataStorage.fiat(userId, walletAddress, remainingWithdrawalBalance, paymentMode, withdrawalAmount, totalWithdrawalBalance);

    const userTransactions = await userDataStorage.getTransactionsForUser(userId, walletAddress);
    console.log("Transactions" , userTransactions)
    if (userTransactions.length > 0) {
    const transaction = userTransactions[0];
    expect(transaction.userId).to.equal(userId);
    console.log("Transaction userID" , transaction.userId);
    expect(transaction.walletAddress).to.equal(walletAddress);
    expect(transaction.paymentMode).to.equal(paymentMode);
    expect(transaction.remainingWithdrawalBalance).to.equal(remainingWithdrawalBalance);
    expect(transaction.withdrawalAmount).to.equal(withdrawalAmount);
    expect(transaction.totalWithdrawalBalance).to.equal(totalWithdrawalBalance);
    // Add more assertions as needed
    }
    expect(userTransactions.length).to.equal(1);

  });


  
});
