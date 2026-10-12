//
//  ProPaywallViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 15/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

/// Hosts the one INTHEGYM pro paywall.
///
/// It is shown two ways. After signup it is a step in the flow: `BasicBaseFlow` sets `onFinish` to
/// enter the app. Everywhere else it is a full-screen modal from `modal(purchaseManager:)` and
/// closing it dismisses. This replaced `AccountCreatedViewController` and
/// `PremiumAccountViewController`, two hosts for two copies of the same screen.
final class ProPaywallViewController: UIViewController {

    // MARK: - Properties
    var display: ProPaywallView!
    var viewModel: ProPaywallViewModel!
    /// What closing does. `nil` dismisses.
    var onFinish: (() -> Void)?

    // MARK: - Initializer
    /// The paywall as a full-screen modal — what every pro gate in the app presents.
    static func modal(purchaseManager: PurchaseManager) -> ProPaywallViewController {
        let vc = ProPaywallViewController()
        vc.viewModel = ProPaywallViewModel(purchaseManager: purchaseManager)
        vc.modalPresentationStyle = .fullScreen
        return vc
    }

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }

    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel) { [weak self] in
            self?.finish()
        }
        addSwiftUIView(display)
    }

    private func finish() {
        if let onFinish {
            onFinish()
        } else {
            dismiss(animated: true)
        }
    }
}
