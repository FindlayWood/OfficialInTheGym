//
//  SubscriptionManager.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import RevenueCat

//class SubscriptionManager: ObservableObject, SubscriptionService {
//    
//    @Published var isSubscribed: Bool = false
//    @Published var subscriptionInfoError: Error?
//    
//    static let shared = SubscriptionManager()
//    
//    private init() {}
//    
//    func launch() async {
////        do {
////            Purchases.configure(with: .init(withAPIKey: Constants.revenueCatAPIKey))
//////            Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)
////            let (purchaseInfo, _) = try await Purchases.shared.logIn(UserDefaults.currentUser.uid)
////            if purchaseInfo.entitlements.all["Premium"]?.isActive == true {
////                isSubscribed = true
////                print("true")
////            } else {
////                isSubscribed = false
////                print("false")
////            }
////        } catch {
////            isSubscribed = false
////            subscriptionInfoError = error
////        }
//    }
//    
//    func getOfferings() async throws -> [Package]? {
//        let offerings = try await Purchases.shared.offerings()
//        return offerings.current?.availablePackages
//    }
//    
//    func purchase(_ package: Package) async throws -> RevenueCatTransactionModel {
//        let purchaseResultData = try await Purchases.shared.purchase(package: package)
//        if purchaseResultData.customerInfo.entitlements.all["Premium"]?.isActive == true {
//            isSubscribed = true
//        }
//        guard let transactionId = purchaseResultData.transaction?.transactionIdentifier,
//              let transactionDate = purchaseResultData.transaction?.purchaseDate,
//              let transactionProductID = purchaseResultData.transaction?.productIdentifier
//        else {
//            throw NSError(domain: "Invalid Transaction Data", code: -1)
//        }
//        let transactionModel = RevenueCatTransactionModel(transactionID: transactionId, transactionDate: transactionDate, productID: transactionProductID, userID: UserDefaults.currentUser.uid)
//        return transactionModel
//    }
//    
//    func getCustomerInfo() async throws -> CustomerInfo {
//        return try await Purchases.shared.customerInfo()
//    }
//    func restorePurchase() async throws {
//        let customerInfo = try await Purchases.shared.restorePurchases()
//        if customerInfo.entitlements.all["Premium"]?.isActive == true {
//            isSubscribed = true
//        } else {
//            isSubscribed = false
//        }
//    }
//    
//    func logOut() async throws {
////        _ = try await Purchases.shared.logOut()
//    }
//}


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


import Combine
import StoreKit

//@MainActor
class StoreKitPurchaseManager: PurchaseManager, ObservableObject {
    
    @Published private(set) var products: [PurchaseableProduct] = []
    var productsPublished: Published<[PurchaseableProduct]> { _products }
    var productsPublisher: Published<[PurchaseableProduct]>.Publisher { $products }

    private let productIds = ["itg_499_1m"]

    private var productsLoaded = false
    
    private var subscriptions = Set<AnyCancellable>()

    func loadProducts() async throws -> [DisplayAndPurchaseProduct] {
        let offerings = try await Purchases.shared.offerings()
        guard let packages = offerings.current?.availablePackages else { return [] }
        return packages
        
//        guard !self.productsLoaded else { return try await Product.products(for: productIds) }
//        self.products = try await Product.products(for: productIds)
//        self.productsLoaded = true
//        
//        return try await Product.products(for: productIds)
    }
    
    func restorePurchase() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        if customerInfo.entitlements.all["Premium"]?.isActive == true {
            givenEntitlement = true
//            isSubscribed = true
        } else {
            givenEntitlement = false
//            isSubscribed = false
        }
    }
    
    func purchase(_ product: PurchaseableProduct) async throws -> PurchaseProductResult {
//        let resultcat = try await Purchases.shared.purchase(product: product)
        let result = try await product.purchaseProduct()

        switch result {
        case .successVerified:
            await self.updatePurchasedProducts()
            // write to firebase transactions
            return result
        case .successUnverified:
            await self.updatePurchasedProducts()
            return result
        case .pending:
            return result
        case .userCancelled:
            return result
        case .failed:
            return result
        }
//        switch result {
//        case let .success(.verified(transaction)):
//           // Successful purhcase
//            await transaction.finish()
//            await self.updatePurchasedProducts()
//        case .success(.unverified(_, _)):
//            // Successful purchase but transaction/receipt can't be verified
//            // Could be a jailbroken phone
//            break
//        case .pending:
//            // Transaction waiting on SCA (Strong Customer Authentication) or
//            // approval from Ask to Buy
//            break
//        case .userCancelled:
//            // ^^^
//            break
//        @unknown default:
//            break
//        }
    }

//    func purchase(_ product: Product) async throws {
//        let uuid = UUID()
//        print("----- user app token \(uuid)")
//        let result = try await product.purchase(options: [.appAccountToken(uuid)])
//
//        switch result {
//        case let .success(.verified(transaction)):
//           // Successful purhcase
//            await transaction.finish()
//            await self.updatePurchasedProducts()
//        case .success(.unverified(_, _)):
//            // Successful purchase but transaction/receipt can't be verified
//            // Could be a jailbroken phone
//            break
//        case .pending:
//            // Transaction waiting on SCA (Strong Customer Authentication) or
//            // approval from Ask to Buy
//            break
//        case .userCancelled:
//            // ^^^
//            break
//        @unknown default:
//            break
//        }
//    }
    
    @Published private(set) var purchasedProductIDs = Set<String>()

    
    func hasUnlocked() async -> Bool {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            if customerInfo.entitlements.all["Premium"]?.isActive == true {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var hasUnlockedPro: Bool {
        return !purchasedProductIDs.isEmpty || givenEntitlement
    }
    
    var givenEntitlement: Bool = false
    var hasBeenSubscription: Bool = false
    

    func updatePurchasedProducts() async {
        do {
            let info = try await Purchases.shared.customerInfo()
            print("-------- entitlements \(info.activeSubscriptions)")
            purchasedProductIDs = info.activeSubscriptions
        }
        catch {
            
        }
//        for await result in Transaction.all {
//            
//            guard case .verified(let transaction) = result else {
//                continue
//            }
//            
//            print("There exists a transaction ---- ")
//        }
//        for await result in Transaction.currentEntitlements {
//            
//            print("-------- got a result ")
//            guard case .verified(let transaction) = result else {
//                continue
//            }
//
//            if transaction.revocationDate == nil {
//                print("------- Adding \(transaction.productID) for user \(UserDefaults.currentUser.id), transaction -> \(String(describing: transaction.appAccountToken))")
//                
////                do {
////                    let json = try JSONSerialization.jsonObject(with: transaction.jsonRepresentation, options: []) as? [String : Any]
////                    print("------- Full JSON -> \(json)")
////                } catch {
////                    print("errorMsg")
////                }
//                self.purchasedProductIDs.insert(transaction.productID)
//            } else {
//                self.purchasedProductIDs.remove(transaction.productID)
//            }
//        }
    }
    
    private var updates: Task<Void, Never>? = nil
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await result in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                print("----- got an update \(result)")
//                await self.updatePurchasedProducts()
            }
        }
    }
    
    func launch() {
        
        Task {
            await checkEntitlements()
        }
        
        NotificationCenter.default.publisher(for: Notification.signOut)
            .sink { [weak self] _ in
                self?.signOutPurchases()
            }
            .store(in: &subscriptions)
        
        NotificationCenter.default.publisher(for: Notification.signIn)
            .sink { [weak self] _ in
                self?.signIn()
            }
            .store(in: &subscriptions)
    }
    
    func signOutPurchases() {
        Task {
//            _ = try await Purchases.shared.logOut()
            givenEntitlement = false
            purchasedProductIDs.removeAll()
            print("----- Removing all product IDs")
        }
    }
    
    func signIn() {
        Task {
            let (_, _) = try await Purchases.shared.logIn(UserDefaults.currentUser.uid)
            await checkEntitlements()
            print("-------- Signing in and checking entitlements")
        }
    }
    
    func checkEntitlements() async {
        do {
            
            let customerInfo = try await Purchases.shared.customerInfo()
            print("---- logged in \(customerInfo.originalAppUserId)")
            let x = customerInfo.originalPurchaseDate
            let y = customerInfo.latestExpirationDate
            print(" ---- all x \(String(describing: x)) & \(String(describing: y))")
            if customerInfo.entitlements.all["Premium"]?.isActive == true {
                givenEntitlement = true
                print("---- true")
            } else {
                givenEntitlement = false
                print("------ false")
            }
        } catch {
            givenEntitlement = false
            print("---- there was an error logging in")
        }
        
        for await result in Transaction.all {
            
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.expirationDate != nil {
                print("There exists a previous transaction ---- \(String(describing: transaction.expirationDate))")
                hasBeenSubscription = true
            }
        }
    }
    
    init() {
        Purchases.configure(withAPIKey: Constants.revenueCatAPIKey)
        updates = observeTransactionUpdates()
        launch()
    }

    deinit {
        updates?.cancel()
    }
}

typealias DisplayAndPurchaseProduct = DisplayableProduct & PurchaseableProduct


class PreviewPurchaseManager: PurchaseManager, ObservableObject {
    var hasUnlockedPro: Bool = false
    
    @Published var products: [PurchaseableProduct] = []
    var productsPublished: Published<[PurchaseableProduct]> { _products }
    var productsPublisher: Published<[PurchaseableProduct]>.Publisher { $products }
    
    func loadProducts() async throws -> [DisplayAndPurchaseProduct] {
        return []
    }
    
    func purchase(_ product: PurchaseableProduct) async throws -> PurchaseProductResult {
        return .failed
    }
    func restorePurchase() async throws {
        
    }
}

