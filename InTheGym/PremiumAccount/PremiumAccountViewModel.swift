//
//  PremiumAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import FirebaseFirestore
import Foundation
import RevenueCat

class PremiumAccountViewModel: ObservableObject {

    @Published var products: [DisplayAndPurchaseProduct] = []
    @Published var isLoading: Bool = false
    @Published var success: Bool = false
    
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
        }
    }
    
    @MainActor
    func purchaseProduct(_ product: PurchaseableProduct) async {
        isLoading = true
        do {
            let result = try await purchaseManager.purchase(product)
            handleResult(result)
            isLoading = false
        } catch {
            print(String(describing: error))
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
            isLoading = true
        }
    }
    
    func handleResult(_ result: PurchaseProductResult) {
        switch result {
        case .successVerified(let purchaseTransaction):
            // write to firebase
            let modelToUpload = mapTransactionModel(purchaseTransaction)
            writeSuccessfulPurchase(modelToUpload)
            DispatchQueue.main.async {
                self.success = true
            }
        case .successUnverified:
            print("success unverified")
        case .pending:
            print("pending")
        case .userCancelled:
            print("user cancelled")
        case .failed:
            print("failed")
        }
    }
    
    func mapTransactionModel(_ model: PurchaseTransaction) -> RemoteUploadPurchaseTransaction {
        RemoteUploadPurchaseTransaction(id: model.id, userID: UserDefaults.currentUser.uid, productID: model.productID, purchaseDate: model.purchaseDate)
    }

    func writeSuccessfulPurchase(_ transaction: RemoteUploadPurchaseTransaction) {
        Task {
            do {
                try await backendService.upload(data: transaction, at: "SubscriptionTransactions")
            } catch {
                print(String(describing: error))
            }
        }
    }
}

extension SubscriptionPeriod {
    var durationTitle: String {
        switch self.unit {
        case .day: return "day"
        case .week: return "week"
        case .month: return "Monthly"
        case .year: return "Yearly"
        @unknown default: return "unknown"
        }
    }
    
    var periodTitle: String {
        let periodString = "\(self.value) \(self.durationTitle)"
        let pluralised = self.value > 1 ? periodString + "s" : periodString
        return pluralised
    }
}

enum SubscriptionError: Error {
    case failedFetchOfferings
    case failedPurchase
}
