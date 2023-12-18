// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UserDataStorage is  OwnableUpgradeable, ReentrancyGuardUpgradeable {

   struct timeStampData{
        uint256 withdrawInitiatedTimeStamp;
        uint256 fiatTimeStamp;
        uint256 cryptoTimeStamp;
        uint256 withdrawalPendingTimeStamp;
        uint256 OrderReceivedTimeStamp;
        uint256 cryptoReceivedTimeStamp;
        uint256 payoutSuccessTimeStamp;
        uint256 refundTimeStamp;
        uint256 adminApproveTimeStamp;
        uint256 adminRejectTimeStamp;
        uint256 adminRetryTimeStamp;
    }

    struct UserData {
        address walletAddress;
        string paymentMode;
        uint256 timestamp;
        uint256 withdrawalAmount;
        uint256 remainingWithdrawalBalance;
        uint256 totalWithdrawalBalance;
        string onMetaTransactionID;
        string userId;
        Status status;
        uint256 refundedAmount;
        uint withdrawCount;
        timeStampData[] allTimeStamps;
    }
 

    enum Status {
        PendingWithdrawal, //0
        OrderReceived, //1
        CryptoReceived, //2
        PayoutSuccess, //3
        Refunded, //4
        Approve, //5
        Reject, //6
        Retry //7
    }
    uint256 private  totalTransactionCount;
    
constructor() {
    totalTransactionCount = 0;
}
    mapping(string => UserData) public userData;
     mapping(address => string[]) private userTransactions;
    uint256 private  countFiatPayments;
    uint256 private  countCryptoPayments;
    uint256 private  countOrderReceived;
    uint256 private  countPending;
    uint256 private  countCryptoReceived;
    uint256 private  countPayoutSuccess;
    uint256 private  countRefunded;
    uint256 private  countApproved;
    uint256 private  countRejected;
    uint256 private  countRetried;

    event Withdrawal(string indexed userId, address walletAddress, string paymentMode, uint256 allTimeStamps, uint256 totalWithdrawalBalance );
    event fiatTransaction(string indexed userId, address walletAddress, string paymentMode, uint256 RemainingWithdrawalBalance, uint256 withdrawalAmount, uint256 fiatTimeStamp, uint256 totalWithdrawalBalance);
    event cryptoTransaction(string indexed userId, address walletAddress, string paymentMode, uint256 RemainingWithdrawalBalance, uint256 withdrawalAmount, uint256 allTimeStamps, uint256 totalWithdrawalBalance);
    event PendingWithdrawalCreated(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID,uint256 allTimeStamps);
    event OrderReceivedCreated(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID , uint256 allTimeStamps );
    event cryptoReceivedCreated(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID ,uint256 allTimeStamps );
    event payoutSuccessCreated(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID ,uint256 allTimeStamps );
    event refundCreated(string indexed userId, address walletAddress, uint256 refundedAmount, Status status, string onMetaTransactionID,uint256 allTimeStamps );
    event adminApproveTransaction(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID ,uint256 allTimeStamps );
    event adminRejectTransaction(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID , uint256 allTimeStamps );
    event adminRetryTransaction(string indexed userId, address walletAddress, uint256 withdrawalAmount, Status status, string onMetaTransactionID ,uint256 allTimeStamps );


 

// Function is triggered when a user clicks on withdraw button

    function withdraw(string memory userId, address walletAddress, string memory paymentMode, uint256 totalWithdrawalBalance) external nonReentrant  {
        require(bytes(userId).length > 0, "Invalid user ID"); 
        require(walletAddress != address(0), "Invalid wallet address"); 
        require(bytes(paymentMode).length > 0, "Invalid payment mode");//cannont be zero

        UserData storage data = userData[userId]; //user ID
        data.walletAddress = walletAddress; //userWallet address
        data.paymentMode = paymentMode; //Mode of payment when user have initiated
        uint256 allTimeStamps = block.timestamp; //time stamp
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered

      
        emit Withdrawal(userId, walletAddress, paymentMode, allTimeStamps ,  totalWithdrawalBalance); //Emits the data specified in the parameters.
    }
// Function is triggered when a user click on fiat payment mode

    function fiat(string memory userId, address walletAddress, uint256 remainingWithdrawalBalance, string memory paymentMode, uint256 withdrawalAmount, uint256 totalWithdrawalBalance) external nonReentrant  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Minimum Withdrawal amount should be greater than 20CFT");
        require(totalWithdrawalBalance >= 0, "Total balance");
        require(bytes(paymentMode).length > 0, "Invalid payment mode");
        require(remainingWithdrawalBalance == totalWithdrawalBalance - withdrawalAmount);

        UserData storage data = userData[userId];
        data.totalWithdrawalBalance = totalWithdrawalBalance;
        data.withdrawalAmount = withdrawalAmount;
        data.remainingWithdrawalBalance = remainingWithdrawalBalance;
        data.walletAddress = walletAddress;
        data.paymentMode = paymentMode;
        uint256 fiatTimeStamp = block.timestamp;
        countFiatPayments++;
        userTransactions[walletAddress].push(userId);
       
          incrementTotalTransactionCount(); //increaments the count when function is triggered

        emit fiatTransaction(userId, walletAddress, paymentMode,  remainingWithdrawalBalance, withdrawalAmount, totalWithdrawalBalance ,fiatTimeStamp); //Emits the data specified in the parameters.
    }
// Function is triggered when a user click on crypto payment mode
    function crypto(string memory userId, address walletAddress, uint256 remainingWithdrawalBalance, string memory paymentMode, uint256 withdrawalAmount, uint256 totalWithdrawalBalance) external nonReentrant  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Minimum Withdrawal amount should be greater than 20CFT");
        require(totalWithdrawalBalance >= 0, "Total balance");
        require(bytes(paymentMode).length > 0, "Invalid payment mode");
        require(remainingWithdrawalBalance == totalWithdrawalBalance - withdrawalAmount);

        UserData storage data = userData[userId];
        data.totalWithdrawalBalance = totalWithdrawalBalance;
        data.withdrawalAmount = withdrawalAmount;
        data.remainingWithdrawalBalance = remainingWithdrawalBalance;
        data.walletAddress = walletAddress;
        data.paymentMode = paymentMode;
        uint256 allTimeStamps = block.timestamp;
        countCryptoPayments++;
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered
        emit cryptoTransaction(userId, walletAddress, paymentMode,allTimeStamps, remainingWithdrawalBalance, withdrawalAmount, totalWithdrawalBalance); //Emits the data specified in the parameters.
    }
// Function is triggered when a user has initialised the order but crypto transfer is pending.
    function withdrawalPending(string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        countPending++;
        data.status = status;
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered


        emit PendingWithdrawalCreated(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID,allTimeStamps); //Emits the data specified in the parameters.

    }
// function is triggered when a user transfers crypto and the tokens are received by Onmeta. 
    function OrderReceived (string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        countOrderReceived++;
        data.status = status;
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered


        emit OrderReceivedCreated(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID,allTimeStamps); //Emits the data specified in the parameters.
    }
// When onMeta successfully validate the crypto received from user and onmeta sends this event. 
    function cryptoReceived (string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        data.onMetaTransactionID = onMetaTransactionID;
        data.status = status;
        countCryptoReceived++;
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered


        emit cryptoReceivedCreated(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID ,allTimeStamps); //Emits the data specified in the parameters.
    }
    // function  is triggered when the fiat amount is successfully deposited in the users bank account 
    function payoutSuccess(string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        countPayoutSuccess++;
        data.status = status;
        userTransactions[walletAddress].push(userId);
          incrementTotalTransactionCount(); //increaments the count when function is triggered

        
        emit payoutSuccessCreated(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID ,allTimeStamps); //Emits the data specified in the parameters.
    }
        // function   is triggered when refund is successfully completed in case of amount/token mismatch 
    function refund(string memory userId, address walletAddress, uint256 refundedAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(refundedAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.refundedAmount = refundedAmount;
        uint256 allTimeStamps = block.timestamp;
        countRefunded++;
        data.status = status;
        userTransactions[walletAddress].push(userId);
        incrementTotalTransactionCount(); //increaments the count when function is triggered


        
        emit refundCreated(userId, walletAddress, refundedAmount, status, onMetaTransactionID ,allTimeStamps); //Emits the data specified in the parameters.
    }

    // function to submit transaction when a user withdraws cryptocurrency which should be approved , Rejected , Retryed from admin pannel

    function adminApprove(string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        countApproved++;
        data.status = status;
        userTransactions[walletAddress].push(userId);
        incrementTotalTransactionCount(); //increaments the count when function is triggered


        
        emit adminApproveTransaction(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID,allTimeStamps); //Emits the data specified in the parameters.
    }
    // function to submit transaction when a user withdraws cryptocurrency which should be approved , Rejected , Retryed from admin pannel

    function adminReject(string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;
        userTransactions[walletAddress].push(userId);
        incrementTotalTransactionCount(); //increaments the count when function is triggered


        data.status = status;

        
        emit adminRejectTransaction(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID , allTimeStamps); //Emits the data specified in the parameters.
    }
    // function to submit transaction when a user withdraws cryptocurrency which should be approved , Rejected , Retryed from admin pannel
   function adminRetry(string memory userId, address walletAddress, uint256 withdrawalAmount, Status status, string memory onMetaTransactionID) external  {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(withdrawalAmount >= 20, "Withdrawal amount must be greater than zero");
        require(bytes(onMetaTransactionID).length > 0, "onMetaTransactionID cannot be empty");

        UserData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 allTimeStamps = block.timestamp;

        data.status = status;
        userTransactions[walletAddress].push(userId);
        incrementTotalTransactionCount(); //increaments the count when function is triggered


        
        emit adminRetryTransaction(userId, walletAddress, withdrawalAmount, status, onMetaTransactionID , allTimeStamps); //Emits the data specified in the parameters.
    
    }

// will get the all transactions data for each user
 function getTransactionsForUser(string memory userId, address walletAddress) external view returns (UserData[] memory) {
        string[] storage userTxList = userTransactions[walletAddress];
        UserData[] memory transactions = new UserData[](userTxList.length);

        for (uint256 i = 0; i < userTxList.length; i++) {
            transactions[i] = userData[userTxList[i]];
        }
        //Gives  the list of transactions history  when function is triggered

        return transactions;
    }


function getStatusFromInt(uint256 statusInt) external pure returns (Status) {
    require(statusInt >= uint256(Status.PendingWithdrawal) && statusInt <= uint256(Status.Retry), "Invalid status integer");
    return Status(statusInt);
}
// When ever there is an transaction that we writing to on-chain it gives total count of transactions
function incrementTotalTransactionCount() internal {
    totalTransactionCount++;
}
// get total transaction count 
function getTotalTransactionCount() external view returns (uint256) {
    return totalTransactionCount;
}




     function getCountFiatPayments() external view returns (uint256) {
        return countFiatPayments;
    }

    function getCountCryptoPayments() external view returns (uint256) {
        return countCryptoPayments;
    }

    function getCountOrderReceived() external view returns (uint256) {
        return countOrderReceived;
    }

    function getCountPending() external view returns (uint256) {
        return countPending;
    }

    function getCountCryptoReceived() external view returns (uint256) {
        return countCryptoReceived;
    }

    function getCountPayoutSuccess() external view returns (uint256) {
        return countPayoutSuccess;
    }

    function getCountRefunded() external view returns (uint256) {
        return countRefunded;
    }

    function getCountApproved() external view returns (uint256) {
        return countApproved;
    }

    function getCountRejected() external view returns (uint256) {
        return countRejected;
    }

    function getCountRetried() external view returns (uint256) {
        return countRetried;
    }




}
