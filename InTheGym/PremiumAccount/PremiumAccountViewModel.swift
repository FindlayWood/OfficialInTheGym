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
    // MARK: - Publishers
    @Published var isLoading = false
    @Published var subscriptionPackages: [Package] = []
    @Published var selectedPackage: Package?
    @Published var selectedSubscription: SubscriptionEnum = .monthly
    @Published var error: SubscriptionError?
    
    @Published var originalPurchaseDate: Date?
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var subscriptionService: SubscriptionService = SubscriptionManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared, subscriptionService: SubscriptionService = SubscriptionManager.shared) {
        self.apiService = apiService
        self.subscriptionService = subscriptionService
    }
    // MARK: - Actions
    
    // MARK: - Methods
    @MainActor
    func fetchIAPOfferings() async {
        do {
            if let packages = try await subscriptionService.getOfferings() {
                subscriptionPackages = packages
                selectedPackage = packages.first
            }
            if subscriptionService.isSubscribed {
                await purchaseInfo()
            }
            
//            let offerings = try await Purchases.shared.offerings()
//            if let packages = offerings.current?.availablePackages {
//                subscriptionPackages = packages
//                selectedPackage = packages.first
//            }
        } catch {
            print(String(describing: error))
            self.error = .failedFetchOfferings
        }
    }
    
    @MainActor
    func subscribeAction() async {
        isLoading = true
        do {
            guard let selectedPackage = selectedPackage else { return }
            let transactionModel = try await subscriptionService.purchase(selectedPackage)
            await uploadTransaction(transactionModel)
            isLoading = false
        } catch {
            self.error = .failedPurchase
            self.isLoading = false
        }
    }
    
    func uploadTransaction(_ model: RevenueCatTransactionModel) async {
        let ref = Firestore.firestore().collection("SubscriptionTransactions")
        do {
            let _ = try ref.addDocument(from: model)
        } catch {
            await uploadTransaction(model)
        }
    }
    
    @MainActor
    func purchaseInfo() async {
        isLoading = true
        do {
            let info = try await subscriptionService.getCustomerInfo()
            originalPurchaseDate = info.originalPurchaseDate
        } catch {
            print(String(describing: error))
        }
    }
    
    @MainActor
    func restorePurchaseAction() async {
        isLoading = true
        do {
            try await subscriptionService.restorePurchase()
            isLoading = false
        } catch {
            print(String(describing: error))
            isLoading = false
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
