// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "../node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "../node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract UserDataStorage is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
  
    // Remove entire TimeStamp Data and keep one time stamp data
    // Check all the camel Cases

    struct TransactionData {
        // Rename UserData to transaction Count
        address walletAddress;
        string paymentMode;
        uint256 initiateTs;
        uint256 withdrawalAmount;
        uint256 remainingWithdrawalBalance;
        uint256 totalWithdrawalBalance;
        string onMetaTransactionID;
        string userId;
        Status status;
        uint256 refundedAmount;
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
    uint256 private totalTransactionCount;

    constructor() {
        totalTransactionCount = 0;
    }

    mapping(string => TransactionData) public userData;
    mapping(string => TransactionData) public withdrawalRequests;

    // User ID To User Transaction  Data.
    // TransactionIs to User Transaction Approach 2
    mapping(address => string[]) private userTransactions;
    uint256 private countFiatPayments;
    uint256 private countCryptoPayments;
    uint256 private countOrderReceived;
    uint256 private countPending;
    uint256 private countCryptoReceived;
    uint256 private countPayoutSuccess;
    uint256 private countRefunded;
    uint256 private countApproved;
    uint256 private countRejected;
    uint256 private countRetried;
    uint256 private withdrawCount;


    event Withdrawal(
        string indexed userId,
        address walletAddress,
        string paymentMode,
        uint256 initiateTs,
        uint256 totalWithdrawalBalance
    );
    event withdrawaTransactionCreated(
        string indexed userId,
        address walletAddress,
        string paymentMode,
        uint256 RemainingWithdrawalBalance,
        uint256 withdrawalAmount,
        uint256 initiateTs,
        uint256 totalWithdrawalBalance
    );
    event updateWithdrawalTransactionStatus(
        string indexed userId,
        address walletAddress,
        uint256 withdrawalAmount,
        Status status,
        string onMetaTransactionID,
        uint256 initiateTs
    );



    function initialize() public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
    }

    // Function is triggered when a user clicks on withdraw button

    function withdrawInitiateRequest(
        string memory userId,
        address walletAddress,
        string memory paymentMode,
        uint256 totalWithdrawalBalance,
         string memory requestId
    ) external nonReentrant onlyOwner {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(bytes(paymentMode).length > 0, "Invalid payment mode"); //cannont be zero

        TransactionData storage data = userData[userId]; //user ID
        data.walletAddress = walletAddress; //userWallet address
        data.paymentMode = paymentMode; //Mode of payment when user have initiated
        uint256 initiateTs = block.timestamp; //time stamp
        userTransactions[walletAddress].push(userId);
        incrementTotalTransactionCount(); //increaments the count when function is triggered
        withdrawCount++;
        withdrawalRequests[requestId] = data;

        emit Withdrawal(
            userId,
            walletAddress,
            paymentMode,
            initiateTs,
            totalWithdrawalBalance
        ); 
    }


   

    function createWithdrawTransaction(
        string memory userId,
        address walletAddress,
        uint256 remainingWithdrawalBalance,
        string memory paymentMode,
        uint256 withdrawalAmount,
        uint256 totalWithdrawalBalance
    ) external nonReentrant onlyOwner {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(
            withdrawalAmount >= 20,
            "Minimum Withdrawal amount should be greater than 20CFT"
        );
        require(totalWithdrawalBalance >= 0, "Total balance");
        require(bytes(paymentMode).length > 0, "Invalid payment mode");
        require(
            remainingWithdrawalBalance ==
                totalWithdrawalBalance - withdrawalAmount
        );

        TransactionData storage data = userData[userId];
        data.totalWithdrawalBalance = totalWithdrawalBalance;
        data.withdrawalAmount = withdrawalAmount;
        data.remainingWithdrawalBalance = remainingWithdrawalBalance;
        data.walletAddress = walletAddress;
        if (compareStrings(paymentMode, "Fiat")) {
            countFiatPayments++;
        } else {
            countCryptoPayments++;
        }
        data.paymentMode = paymentMode;
        uint256 initiateTs = block.timestamp;
        userTransactions[walletAddress].push(userId);

        incrementTotalTransactionCount();

        emit withdrawaTransactionCreated(
            userId,
            walletAddress,
            paymentMode,
            remainingWithdrawalBalance,
            withdrawalAmount,
            totalWithdrawalBalance,
            initiateTs
        );
    }


    function updateWithdrawTransactions(
        string memory userId,
        address walletAddress,
        uint256 withdrawalAmount,
        Status status,
        string memory onMetaTransactionID
    ) external nonReentrant onlyOwner returns (Status) {
        require(bytes(userId).length > 0, "Invalid user ID");
        require(walletAddress != address(0), "Invalid wallet address");
        require(
            withdrawalAmount >= 20,
            "Withdrawal amount must be greater than zero"
        );
        require(
            bytes(onMetaTransactionID).length > 0,
            "onMetaTransactionID cannot be empty"
        );

        TransactionData storage data = userData[userId];
        data.walletAddress = walletAddress;
        data.withdrawalAmount = withdrawalAmount;
        uint256 initiateTs = block.timestamp;
        data.onMetaTransactionID = onMetaTransactionID;

        // Depending on the 'status' input, update the appropriate count
        if (status == Status.PendingWithdrawal) {
            countPending++;
            incrementTotalTransactionCount();
        } else if (status == Status.OrderReceived) {
            countOrderReceived++;
            incrementTotalTransactionCount();
        } else if (status == Status.CryptoReceived) {
            countCryptoReceived++;
            incrementTotalTransactionCount();
        } else if (status == Status.PayoutSuccess) {
            countPayoutSuccess++;
            countFiatPayments++;
            incrementTotalTransactionCount();
        } else if (status == Status.Refunded) {
            countRefunded++;
            incrementTotalTransactionCount();
            data.refundedAmount = withdrawalAmount;
        } 
         else if (status == Status.Approve) {
            countApproved++;
            countCryptoPayments++;
            incrementTotalTransactionCount();
        } else if (status == Status.Reject) {
            countRejected++;
            incrementTotalTransactionCount();
        } else if (status == Status.Retry) {
            countRetried++;
            incrementTotalTransactionCount();
        } else {
            revert("invalid status");
        }

        data.status = status;
        userTransactions[walletAddress].push(userId);
        emit updateWithdrawalTransactionStatus(
            userId,
            walletAddress,
            withdrawalAmount,
            status,
            onMetaTransactionID,
            initiateTs
        );

        return status; // Return the updated status.
    }



    // will get the all transactions data for each user

    function getTransactionsForUser(string memory userId, address walletAddress)
        external
        onlyOwner
        view
        returns (TransactionData[] memory)
    {
        string[] storage userTxList = userTransactions[walletAddress];
        TransactionData[] memory transactions = new TransactionData[](userTxList.length);

        for (uint256 i = 0; i < userTxList.length; i++) {
            transactions[i] = userData[userTxList[i]];
        }
        //Gives  the list of transactions history  when function is triggered

        return transactions;
    }

    function getStatusFromInt(uint256 statusInt)
        external
        pure
        returns (Status)
    {
        require(
            statusInt >= uint256(Status.PendingWithdrawal) &&
                statusInt <= uint256(Status.Retry),
            "Invalid status integer"
        );
        return Status(statusInt);
    }

    // When ever there is an transaction that we writing to on-chain it gives total count of transactions
    function incrementTotalTransactionCount() internal onlyOwner {
        totalTransactionCount++;
    }

    // get total transaction count
    function getTotalTransactionCount() external onlyOwner view returns (uint256) {
        return totalTransactionCount;
    }

    function getCountFiatPayments() external onlyOwner view returns (uint256) {
        return countFiatPayments;
    }

    function getCountCryptoPayments() external onlyOwner view returns (uint256) {
        return countCryptoPayments;
    }
    function getWithdrawalCount() external onlyOwner view  returns (uint256){
        return withdrawCount;
    }
    function getCountOrderReceived() external onlyOwner view returns (uint256) {
        return countOrderReceived;
    }

    function getCountPending() external onlyOwner view returns (uint256) {
        return countPending;
    }

    function getCountCryptoReceived() external onlyOwner view returns (uint256) {
        return countCryptoReceived;
    }

    function getCountPayoutSuccess() external onlyOwner view returns (uint256) {
        return countPayoutSuccess;
    }

    function getCountRefunded() external onlyOwner view returns (uint256) {
        return countRefunded;
    }

    function getCountApproved() external onlyOwner view returns (uint256) {
        return countApproved;
    }

    function getCountRejected() external onlyOwner view returns (uint256) {
        return countRejected;
    }

    function getCountRetried() external onlyOwner view returns (uint256) {
        return countRetried;
    }

    function compareStrings(string memory a, string memory b)
        internal
        
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

        function getTransactionDataByRequestId(string memory requestId) external view returns (TransactionData memory) {
        // by using  the withdrawalRequests  to see  the data
        return withdrawalRequests[requestId];
    }
}
