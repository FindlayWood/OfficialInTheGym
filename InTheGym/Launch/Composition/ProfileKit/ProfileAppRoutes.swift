//
//  ProfileAppRoutes.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import StoreKit
import UIKit

/// The app-target screens the PROFILE tab opens but ProfileKit cannot build:
/// the INTHEGYM pro paywall, the App Store's subscription management and the
/// About page. `ProfileKitComposition` wires
/// these into `ProfileKitRouter`'s `on…` closures.
///
/// Each is opened exactly as the legacy "More" menu and settings opened it
/// (`PlayerProfileMoreCoordinator`, `SettingsViewController`), so nothing about
/// those screens changes by moving the door.
///
/// Performance Center used to open from here too. It is the player tab bar's
/// PERFORMANCE tab now (`PlayerInitialViewController`).
///
/// The router holds this object through its closures, and it holds the
/// navigation controller weakly, because the navigation controller holds the
/// router.
final class ProfileAppRoutes {

    // MARK: - Properties
    private weak var navigationController: UINavigationController?
    private let purchaseManager: PurchaseManager

    // MARK: - Initializer
    init(navigationController: UINavigationController, purchaseManager: PurchaseManager) {
        self.navigationController = navigationController
        self.purchaseManager = purchaseManager
    }
}

// MARK: - Routes
extension ProfileAppRoutes {

    func showPaywall() {
        let vc = PremiumAccountViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel = PremiumAccountViewModel(purchaseManager: purchaseManager)
        navigationController?.present(vc, animated: true)
    }

    func showManageSubscription() {
        guard let scene = navigationController?.view.window?.windowScene else { return }
        Task { @MainActor in
            do {
                try await AppStore.showManageSubscriptions(in: scene)
            } catch {
                print("❌ Manage subscriptions failed: \(error)")
            }
        }
    }

    func showAbout() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BestUseMessageViewController")
        navigationController?.pushViewController(vc, animated: true)
    }
}
