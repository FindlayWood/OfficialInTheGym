//
//  ProPaywallViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/10/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import Foundation

/// The one paywall's state — after signup and everywhere pro is asked for in the app.
///
/// There used to be two: `AccountCreatedViewModel` for onboarding and `PremiumAccountViewModel` for
/// every in-app entry point, line-for-line the same except that the second had kept the bug the
/// first had fixed — `isLoading = true` in its `catch` blocks, which hid the purchase button for
/// good after one failure. Two copies of a purchase flow is two places for that to happen again.
@MainActor
final class ProPaywallViewModel: ObservableObject {

    // MARK: - Publishers
    @Published private(set) var plans: [ProPlan] = []
    @Published var selectedPlanId: String?
    @Published private(set) var isLoadingPlans = false
    @Published private(set) var isPurchasing = false
    @Published private(set) var step: ProPaywallStep
    @Published var error: PurchaseError?

    // MARK: - Properties
    let purchaseManager: PurchaseManager
    private let backendService: FirestoreService
    private let trialReminder: TrialReminderScheduling

    // MARK: - Initializer
    /// `nonisolated` so the legacy coordinators, which are not main-actor types, can build one.
    nonisolated init(
        purchaseManager: PurchaseManager,
        backendService: FirestoreService = FirestoreManager.shared,
        trialReminder: TrialReminderScheduling = LocalNotificationTrialReminder()
    ) {
        self.purchaseManager = purchaseManager
        self.backendService = backendService
        self.trialReminder = trialReminder
        // Already pro (a restored account, a second device) opens on the success screen.
        self._step = Published(initialValue: purchaseManager.hasUnlockedPro ? .success(trial: nil, isReminded: false) : .paywall)
    }

    var selectedPlan: ProPlan? {
        plans.first { $0.id == selectedPlanId }
    }

    /// What the recommended plan's saving is measured against: the next-shorter plan — monthly,
    /// for yearly. Comparing yearly with weekly would be true but inflated; nobody choosing between
    /// them is weighing a year of weekly payments.
    var savingsBaseline: ProPlan? {
        plans
            .filter { $0.period < ProPlan.recommendedPeriod }
            .max { $0.period < $1.period }
    }

    /// "Start free trial" when the selected plan gives this user a trial, "Subscribe" otherwise.
    var buttonTitle: String {
        selectedPlan?.freeTrialDays != nil ? "Start free trial" : "Subscribe"
    }

    /// The terms of the selected plan, in one line under the button. Apple requires the price and
    /// what happens when a trial ends to be clear before the purchase sheet; it is also the sentence
    /// that makes a trial feel safe.
    var termsText: String {
        guard let plan = selectedPlan else { return "Cancel anytime." }
        if let days = plan.freeTrialDays {
            return "\(days) days free, then \(plan.priceText). Cancel anytime."
        }
        return "\(plan.priceText). Renews automatically. Cancel anytime."
    }

    // MARK: - Plans
    func loadPlans() async {
        guard plans.isEmpty, !isLoadingPlans else { return }
        isLoadingPlans = true
        defer { isLoadingPlans = false }
        do {
            plans = ProPlan.plans(from: try await purchaseManager.loadProducts())
            selectedPlanId = (plans.first { $0.isRecommended } ?? plans.first)?.id
            if plans.isEmpty {
                error = .loadingProducts
            }
        } catch {
            print(String(describing: error))
            self.error = .loadingProducts
        }
    }

    func retry() async {
        let retryable = error?.isRetryable == true
        error = nil
        if retryable {
            await loadPlans()
        }
    }

    // MARK: - Reminder
    /// "Remind me": shows the system prompt and, if allowed, schedules the reminder. A refusal moves
    /// on without one rather than asking again — the success screen says when the trial ends either
    /// way.
    func allowTrialReminder() async {
        guard case .trialReminder(let trial, _) = step else { return }
        let allowed = await trialReminder.requestPermission()
        finishTrial(trial, remind: allowed)
    }

    /// "Not now", or "Continue without a reminder" after notifications were turned off.
    func skipTrialReminder() {
        guard case .trialReminder(let trial, _) = step else { return }
        finishTrial(trial, remind: false)
    }

    /// Re-read when the app comes back to the front: someone sent to Settings to turn notifications
    /// on should get their reminder without having to find a second button.
    func recheckTrialReminderPermission() async {
        guard case .trialReminder(let trial, .denied) = step else { return }
        if await trialReminder.permission() == .allowed {
            finishTrial(trial, remind: true)
        }
    }

    private func finishTrial(_ trial: StartedTrial, remind: Bool) {
        if remind {
            trialReminder.scheduleReminder(for: trial)
        }
        step = .success(trial: trial, isReminded: remind)
    }

    // MARK: - Purchase
    func purchaseSelectedPlan() async {
        guard let plan = selectedPlan, !isPurchasing else { return }
        isPurchasing = true
        // Always cleared — the old paywall set `isLoading = true` on failure, soft-locking itself.
        defer { isPurchasing = false }
        do {
            let result = try await purchaseManager.purchase(plan.product)
            await handle(result, for: plan)
        } catch {
            print(String(describing: error))
            self.error = .purchasingProduct
        }
    }

    func restorePurchase() async {
        isPurchasing = true
        defer { isPurchasing = false }
        do {
            try await purchaseManager.restorePurchase()
            if purchaseManager.hasUnlockedPro {
                step = .success(trial: nil, isReminded: false)
            } else {
                error = .nothingToRestore
            }
        } catch {
            print(String(describing: error))
            self.error = .restorePurchases
        }
    }

    #if EMULATOR
    /// Unlocks pro across the app for this session. See `EmulatorPurchaseManager`.
    func unlockForTesting() {
        (purchaseManager as? EmulatorPurchaseManager)?.unlockForTesting()
        step = .success(trial: nil, isReminded: false)
    }
    #endif

    private func handle(_ result: PurchaseProductResult, for plan: ProPlan) async {
        switch result {
        case .successVerified(let transaction):
            writeSuccessfulPurchase(transaction)
            guard let days = plan.freeTrialDays else {
                step = .success(trial: nil, isReminded: false)
                return
            }
            let trial = StartedTrial(startedAt: transaction.purchaseDate, days: days, priceText: plan.priceText)
            // Already allowed: no need to ask, the paywall promised it.
            let permission = await trialReminder.permission()
            if permission == .allowed {
                finishTrial(trial, remind: true)
            } else {
                step = .trialReminder(trial, permission)
            }
        case .successUnverified:
            print("success unverified")
        case .pending:
            print("pending")
        case .userCancelled:
            break
        case .failed:
            error = .handleResult
        }
    }

    private func writeSuccessfulPurchase(_ transaction: PurchaseTransaction) {
        let model = RemoteUploadPurchaseTransaction(
            userID: UserDefaults.currentUser.uid,
            productID: transaction.productID,
            purchaseDate: transaction.purchaseDate,
            transactionID: transaction.transactionID
        )
        let backendService = backendService
        Task {
            do {
                try await backendService.upload(data: model, at: "SubscriptionTransactions/\(model.id)")
            } catch {
                print(String(describing: error))
            }
        }
    }
}
