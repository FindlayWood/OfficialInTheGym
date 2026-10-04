//
//  ProfileSettingsScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// Settings, pushed from the gear on the profile. See `ProfileSettingsViewModel`
/// for what came across from the legacy screens and what did not.
///
/// **Resetting the password and logging out each ask first**, as they did
/// before. One sends an email the user may not want, and the other ends the
/// session. Both are alerts rather than a bottom sheet because, on this screen,
/// nothing else competes for the bottom edge.
struct ProfileSettingsScreen: View {

    @ObservedObject var viewModel: ProfileSettingsViewModel
    @Environment(\.openURL) private var openURL

    @State private var confirmingPasswordReset = false
    @State private var confirmingSignOut = false
    @State private var confirmingGoPublic = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                subscriptionSection
                accountSection
                toolsSection
                aboutSection
                signOutSection
            }
            .padding(16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.refreshSubscription() }
        .task { await viewModel.loadPrivacy() }
        .alert("Make Account Public?", isPresented: $confirmingGoPublic) {
            Button("Make Public") { Task { await viewModel.setPrivate(false) } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Anyone will be able to follow you, and any follow requests waiting will be approved.")
        }
        .alert("Reset Password?", isPresented: $confirmingPasswordReset) {
            Button("Send Email") { Task { await viewModel.sendPasswordReset() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We'll email you a link to choose a new password.")
        }
        .alert("Log Out?", isPresented: $confirmingSignOut) {
            Button("Log Out", role: .destructive) { Task { await viewModel.signOut() } }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You'll need to log in again next time you open the app.")
        }
        .alert("Couldn't Log Out", isPresented: $viewModel.didFailToSignOut) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Check your connection and try again.")
        }
    }

    // MARK: - Subscription

    private var subscriptionSection: some View {
        ProfileSettingsSection(title: "Subscription") {
            ProfileSettingsRow(
                icon: "crown.fill",
                title: "INTHEGYM pro",
                tint: .premiumColor,
                trailing: .detail(viewModel.hasUnlockedPro ? "Active" : "Not subscribed")
            )
            if viewModel.hasUnlockedPro {
                ProfileSettingsRow(icon: "creditcard", title: "Manage Subscription") {
                    viewModel.onManageSubscription?()
                }
            } else {
                ProfileSettingsRow(icon: "sparkles", title: "Upgrade to pro") {
                    viewModel.onShowPaywall?()
                }
            }
            ProfileSettingsRow(
                icon: "arrow.clockwise",
                title: "Restore Purchases",
                trailing: restoreTrailing,
                showsDivider: false
            ) {
                Task { await viewModel.restorePurchases() }
            }
        }
    }

    private var restoreTrailing: ProfileSettingsRow.Trailing {
        switch viewModel.restoreState {
        case .idle: .chevron
        case .working: .progress
        case .succeeded: .detail(viewModel.hasUnlockedPro ? "Restored" : "Nothing to restore")
        case .failed: .detail("Failed, try again")
        }
    }

    // MARK: - Account

    private var accountSection: some View {
        ProfileSettingsSection(title: "Account", footer: privacyFooter) {
            ProfileSettingsToggleRow(
                icon: "lock",
                title: "Private Account",
                isOn: Binding(
                    get: { viewModel.isPrivate ?? false },
                    set: { newValue in
                        if newValue {
                            Task { await viewModel.setPrivate(true) }
                        } else {
                            confirmingGoPublic = true
                        }
                    }
                ),
                isSaving: viewModel.isSavingPrivacy,
                isEnabled: viewModel.isPrivate != nil
            )
            ProfileSettingsRow(icon: "figure.stand", title: "Body Measurements") {
                viewModel.onOpenBodyMeasurements?()
            }
            ProfileSettingsRow(
                icon: "key",
                title: "Reset Password",
                trailing: passwordResetTrailing,
                showsDivider: false
            ) {
                confirmingPasswordReset = true
            }
        }
    }

    private var privacyFooter: String {
        if let error = viewModel.privacyError { return error }
        return viewModel.isPrivate == true
            ? "New followers need your approval. People already following you stay."
            : "Anyone can follow you. Turn this on to approve new followers first."
    }

    private var passwordResetTrailing: ProfileSettingsRow.Trailing {
        switch viewModel.passwordResetState {
        case .idle: .chevron
        case .working: .progress
        case .succeeded: .detail("Email sent")
        case .failed: .detail("Failed, try again")
        }
    }

    // MARK: - Tools

    private var toolsSection: some View {
        ProfileSettingsSection(title: "Tools") {
            ProfileSettingsRow(icon: "gauge.with.dots.needle.67percent", title: "Performance Center", showsDivider: false) {
                viewModel.onOpenPerformanceCenter?()
            }
        }
    }

    // MARK: - About

    private var aboutSection: some View {
        ProfileSettingsSection(title: "About") {
            ProfileSettingsRow(icon: "info.circle", title: "About INTHEGYM") {
                viewModel.onOpenAbout?()
            }
            ProfileSettingsRow(icon: "camera", title: "Instagram") {
                openURL(viewModel.links.instagram)
            }
            ProfileSettingsRow(icon: "globe", title: "Website") {
                openURL(viewModel.links.website)
            }
            ProfileSettingsRow(icon: "envelope", title: "Contact", trailing: .detail(viewModel.links.contactEmail)) {
                if let url = viewModel.links.contactURL { openURL(url) }
            }
            ProfileSettingsRow(icon: "paintpalette", title: "Icons by Icons8") {
                openURL(viewModel.links.icons)
            }
            ProfileSettingsRow(
                icon: "number",
                title: "Version",
                trailing: .detail(viewModel.appVersion),
                showsDivider: false
            )
        }
    }

    // MARK: - Sign out

    private var signOutSection: some View {
        ProfileSettingsSection(title: "Session") {
            ProfileSettingsRow(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Log Out",
                isDestructive: true,
                trailing: viewModel.isSigningOut ? .progress : .none,
                showsDivider: false
            ) {
                confirmingSignOut = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileSettingsScreen(
            viewModel: ProfileSettingsViewModel(
                subscription: PreviewProfileSubscriptionService(),
                signOutService: PreviewAccountServices(),
                passwordReset: PreviewAccountServices(),
                privateAccountLoader: PreviewPrivacyServices(),
                privateAccountWriter: PreviewPrivacyServices(),
                links: ProfileSettingsLinks(
                    instagram: URL(string: "https://instagram.com")!,
                    website: URL(string: "https://example.com")!,
                    icons: URL(string: "https://icons8.com")!,
                    contactEmail: "officialinthegym@gmail.com"
                )
            )
        )
    }
}
