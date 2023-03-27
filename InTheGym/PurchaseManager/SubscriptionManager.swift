//
//  SubscriptionManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import RevenueCat

class SubscriptionManager: ObservableObject, SubscriptionService {
    
    @Published var isSubscribed: Bool = false
    @Published var subscriptionInfoError: Error?
    
    static let shared = SubscriptionManager()
    
    private init() {}
    
    func launch() async {
        do {
            Purchases.configure(with: .init(withAPIKey: Constants.revenueCatAPIKey).with(usesStoreKit2IfAvailable: true))
//            Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)
            let (purchaseInfo, created) = try await Purchases.shared.logIn(UserDefaults.currentUser.uid)
            if purchaseInfo.entitlements.all["Premium"]?.isActive == true {
                isSubscribed = true
                print("true")
            } else {
                isSubscribed = false
                print("false")
            }
        } catch {
            isSubscribed = false
            subscriptionInfoError = error
        }
    }
    
    func getOfferings() async throws -> [Package]? {
        let offerings = try await Purchases.shared.offerings()
        return offerings.current?.availablePackages
    }
    
    func purchase(_ package: Package) async throws -> RevenueCatTransactionModel {
        let purchaseResultData = try await Purchases.shared.purchase(package: package)
        if purchaseResultData.customerInfo.entitlements.all["Premium"]?.isActive == true {
            isSubscribed = true
        }
        guard let transactionId = purchaseResultData.transaction?.transactionIdentifier,
              let transactionDate = purchaseResultData.transaction?.purchaseDate,
              let transactionProductID = purchaseResultData.transaction?.productIdentifier
        else {
            throw NSError(domain: "Invalid Transaction Data", code: -1)
        }
        let transactionModel = RevenueCatTransactionModel(transactionID: transactionId, transactionDate: transactionDate, productID: transactionProductID, userID: UserDefaults.currentUser.uid)
        return transactionModel
    }
    
    func getCustomerInfo() async throws -> CustomerInfo {
        return try await Purchases.shared.customerInfo()
    }
    func restorePurchase() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        if customerInfo.entitlements.all["Premium"]?.isActive == true {
            isSubscribed = true
        } else {
            isSubscribed = false
        }
    }
    
    func logOut() async throws {
        let customerInfo = try await Purchases.shared.logOut()
    }
}


struct RevenueCatTransactionModel: Codable {
    let transactionID: String
    let transactionDate: Date
    let productID: String
    let userID: String
}

protocol SubscriptionService {
    var isSubscribed: Bool { get }
    func launch() async
    func getOfferings() async throws -> [Package]?
    func purchase(_ package: Package) async throws -> RevenueCatTransactionModel
    func getCustomerInfo() async throws -> CustomerInfo
    func restorePurchase() async throws
    func logOut() async throws
}
