//
//  ProPaywallView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import SwiftUI

/// INTHEGYM pro — the one paywall, after signup and at every pro gate in the app.
///
/// Read top to bottom it answers the questions in the order a user asks them: what do I get
/// (`ProFeatureList`), what does it cost (`ProPlanCard` ×3, monthly recommended), what happens if I
/// try it (`ProTrialTimeline`, with the charge date on screen), and how do I get out (the pinned
/// line under the button, and the close button that is always there).
///
/// **A paywall must always be dismissible.** The close button is never hidden, delayed or
/// disabled — not while loading, not after an error, not mid-purchase. The old one once soft-locked
/// onboarding by hiding its way out behind a stuck spinner.
struct ProPaywallView: View {

    @ObservedObject var viewModel: ProPaywallViewModel

    var onClose: (() -> Void)?

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        switch viewModel.step {
        case .paywall:
            paywall
        case let .trialReminder(trial, permission):
            TrialReminderPermissionScreen(
                trial: trial,
                permission: permission,
                onAllow: { Task { await viewModel.allowTrialReminder() } },
                onSkip: { viewModel.skipTrialReminder() }
            )
            // Back from Settings with notifications turned on: schedule it without a second tap.
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    Task { await viewModel.recheckTrialReminderPermission() }
                }
            }
        case let .success(trial, isReminded):
            PurchaseSuccessSubview(trial: trial, isReminded: isReminded, action: { onClose?() })
        }
    }

    // MARK: - Paywall
    private var paywall: some View {
        VStack(spacing: 0) {
            topBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    hero
                    ProFeatureList()
                    plansSection
                    if let plan = viewModel.selectedPlan, let days = plan.freeTrialDays {
                        ProTrialTimeline(trial: StartedTrial(startedAt: Date(), days: days, priceText: plan.priceText))
                        .transition(.opacity)
                    }
                    footerLinks
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 24)
            }

            bottomBar
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .task {
            await viewModel.loadPlans()
        }
    }

    private var topBar: some View {
        HStack {
            Spacer()
            Button {
                onClose?()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(Color(.secondarySystemBackground)))
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Close")
        }
        .padding(.horizontal, 12)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("INTHEGYM")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Color(.adaptiveDarkColour))
                Text("pro")
                    .font(.system(size: 24, weight: .heavy))
                    .foregroundStyle(Color(.premiumColour))
            }
            Text("Train with the full picture.")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Your stats, your clips and your performance tests — everything you log, turned into progress you can see.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Plans
    private var plansSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your plan")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .textCase(.uppercase)
                .tracking(0.8)

            if viewModel.isLoadingPlans && viewModel.plans.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.plans) { plan in
                        ProPlanCard(
                            plan: plan,
                            savingsPercent: savings(for: plan),
                            badgeTitle: plan.isRecommended ? plan.badgeTitle(among: viewModel.plans) : nil,
                            isSelected: viewModel.selectedPlanId == plan.id,
                            onTap: {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedPlanId = plan.id
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    /// Only the recommended plan states a saving — see `ProPlan`.
    private func savings(for plan: ProPlan) -> Int? {
        guard plan.isRecommended, let baseline = viewModel.savingsBaseline else { return nil }
        return plan.savingsPercent(against: baseline)
    }

    // MARK: - Footer
    private var footerLinks: some View {
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                Button {
                    Task { await viewModel.restorePurchase() }
                } label: {
                    Text("Restore Purchases")
                }
                Link("Terms of Use", destination: ProPaywallLinks.termsOfUse)
                if let privacy = ProPaywallLinks.privacyPolicy {
                    Link("Privacy Policy", destination: privacy)
                }
            }
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.secondary)

            Text("Subscriptions renew automatically at the price shown until cancelled. Cancel at least 24 hours before the end of a trial or period to avoid being charged, in Settings → Apple ID → Subscriptions.")
                .font(.system(size: 11))
                .foregroundStyle(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            #if EMULATOR
            Button {
                viewModel.unlockForTesting()
            } label: {
                Label("Unlock pro for testing", systemImage: "hammer.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(.adaptiveDarkColour))
            }
            #endif
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 10) {
                if let error = viewModel.error {
                    PurchaseErrorBanner(
                        message: error.description,
                        actionTitle: error.isRetryable ? "Try Again" : "OK"
                    ) {
                        Task { await viewModel.retry() }
                    }
                }

                Button {
                    Task { await viewModel.purchaseSelectedPlan() }
                } label: {
                    ZStack {
                        if viewModel.isPurchasing {
                            ProgressView()
                                .tint(Color.white)
                        } else {
                            Text(viewModel.buttonTitle)
                                .font(.system(size: 17, weight: .semibold))
                        }
                    }
                    .foregroundStyle(canPurchase ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(canPurchase ? Color(.premiumColour) : Color(.tertiarySystemFill))
                    )
                }
                .disabled(!canPurchase)
                .animation(.easeInOut(duration: 0.15), value: canPurchase)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.premiumColour))
                    Text(viewModel.termsText)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
                .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }

    private var canPurchase: Bool {
        viewModel.selectedPlan != nil && !viewModel.isPurchasing
    }
}

#Preview {
    ProPaywallView(
        viewModel: ProPaywallViewModel(purchaseManager: PreviewPurchaseManager())
    )
}
