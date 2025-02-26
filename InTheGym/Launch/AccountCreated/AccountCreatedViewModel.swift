//
//  AccountCreatedViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/10/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import Foundation
import StoreKit

class AccountCreatedViewModel: ObservableObject {
    
    @Published var products: [DisplayAndPurchaseProduct] = []
    @Published var isLoading: Bool = false
    @Published var success: Bool = false
    @Published var error: PurchaseError?
    
    var purchaseManager: PurchaseManager
    var backendService: FirestoreService
    
    init(purchaseManager: PurchaseManager, backendService: FirestoreService = FirestoreManager.shared) {
        self.purchaseManager = purchaseManager
        self.backendService = backendService
    }
    
    @MainActor
    func loadProducts() async {
        do {
            let p = try await purchaseManager.loadProducts()
            products = p
        } catch {
            print(String(describing: error))
            self.error = .loadingProducts
        }
    }
    
    func purchaseProduct(_ product: PurchaseableProduct) async {
        isLoading = true
        do {
            let result = try await purchaseManager.purchase(product)
            handleResult(result)
            isLoading = false
        } catch {
            print(String(describing: error))
            self.error = .purchasingProduct
            isLoading = true
        }
    }
    
    func restorePurchase() async {
        isLoading = true
        do {
            try await purchaseManager.restorePurchase()
            print("---- restore was successful")
            isLoading = false
        } catch {
            print(String(describing: error))
            print("---- restore was un successful")
            self.error = .restorePurchases
            isLoading = true
        }
    }
    
    func handleResult(_ result: PurchaseProductResult) {
        switch result {
        case .successVerified(let purchaseTransaction):
            // write to firebase
            let modelToUpload = mapTransactionModel(purchaseTransaction)
            writeSuccessfulPurchase(modelToUpload)
            success = true
        case .successUnverified:
            print("success unverified")
        case .pending:
            print("pending")
        case .userCancelled:
            print("user cancelled")
        case .failed:
            print("failed")
            self.error = .handleResult
        }
    }
    
    func mapTransactionModel(_ model: PurchaseTransaction) -> RemoteUploadPurchaseTransaction {
        RemoteUploadPurchaseTransaction(userID: UserDefaults.currentUser.uid, productID: model.productID, purchaseDate: model.purchaseDate, transactionID: model.transactionID)
    }

    func writeSuccessfulPurchase(_ transaction: RemoteUploadPurchaseTransaction) {
        Task {
            do {
                try await backendService.upload(data: transaction, at: "SubscriptionTransactions/\(transaction.id)")
            } catch {
                print(String(describing: error))
            }
        }
    }
}
