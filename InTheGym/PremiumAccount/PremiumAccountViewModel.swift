//
//  PremiumAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import RevenueCat

class PremiumAccountViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var subscriptionPackages: [Package] = []
    @Published var selectedPackage: Package?
    @Published var selectedSubscription: SubscriptionEnum = .monthly
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    
    // MARK: - Methods
    func fetchIAPOfferings() async {
        do {
            let offerings = try await Purchases.shared.offerings()
            if let packages = offerings.current?.availablePackages {
                subscriptionPackages = packages
                selectedPackage = packages.first
            }
        } catch {
            print(String(describing: error))
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
