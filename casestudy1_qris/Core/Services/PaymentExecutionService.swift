//
//  PaymentExecutionService.swift
//  casestudy1_qris
//
//  Created by Kenneth Mayer on 20/05/26.
//

import Foundation

//validate balance -> submit to gateway -> deduct -> history

protocol PaymentExecutionService {
    func execute(_ transaction: QRISTransaction) async -> Result<PaymentReceipt, Error>
}

final class DefaultPaymentExecutionService: PaymentExecutionService {
    
    private let balanceRepository: BalanceRepository
    private let transactionRepository: TransactionRepository
    private let gateway: PaymentGateway
    
    init(
        balanceRepository: BalanceRepository,
        transactionRepository: TransactionRepository,
        gateway: PaymentGateway
    ) {
        self.balanceRepository = balanceRepository
        self.transactionRepository = transactionRepository
        self.gateway = gateway
    }
    
    func execute(_ transaction: QRISTransaction) async -> Result<PaymentReceipt, Error> {
        // check balance is enough
        guard balanceRepository.currentBalance() >= transaction.amount else {
            return .failure(BalanceError.insufficientFunds(balance: balanceRepository.currentBalance(), required: transaction.amount))
        }
        
        do {
            let receipt = try await gateway.submit(transaction)
            do {
                try balanceRepository.deduct(transaction.amount)
            } catch {
                // gateway access success but local deduct failed
                return .failure(error)
            }
            transactionRepository.add(PaymentRecord(
                bank: transaction.bank,
                transactionId: transaction.transactionId,
                merchantName: transaction.merchantName,
                amount: transaction.amount,
                referenceId: receipt.referenceId,
                timestamp: receipt.approvedAt
            ))
            return .success(receipt)
        } catch {
            return .failure(error)
        }
    }
}
