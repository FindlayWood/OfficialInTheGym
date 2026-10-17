//
//  PurchaseSuccessSubview.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/12/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import SwiftUI
import RevenueCat

struct PurchaseSuccessSubview: View {

    /// Set when the purchase started a free trial: the screen then says when it ends and whether a
    /// reminder is coming, so the last thing the user reads about the trial is its date.
    var trial: StartedTrial? = nil
    var isReminded: Bool = false
    var action: (() -> ())

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 88, height: 88)
                .foregroundStyle(Color(.premiumColour))

            Text("You're in")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
                .padding(.top, 20)

            Text("INTHEGYM pro is unlocked. Manage or cancel it any time in Settings.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 6)

            if let trial {
                Text(trialText(trial))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(14)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.top, 20)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    action()
                } label: {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.premiumColour))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                // RevenueCat is never configured in emulator builds, and `Purchases.shared` traps
                // when it is not — this screen is reachable there now that pro can be unlocked.
                if Purchases.isConfigured {
                    Button {
                        openManageSubscriptions()
                    } label: {
                        Text("Manage Subscription")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private func trialText(_ trial: StartedTrial) -> String {
        let ends = "Your free trial ends on \(StartedTrial.display(trial.endsAt))."
        return isReminded
            ? "\(ends) We'll remind you the day before."
            : "\(ends) Cancel before then in Settings and you won't be charged."
    }

    private func openManageSubscriptions() {
        Purchases.shared.showManageSubscriptions(completion: { error in
            if let error {
                print("Failed to open subscriptions: \(error)")
            }
        })
    }
}

#Preview {
    PurchaseSuccessSubview(action: {})
}
