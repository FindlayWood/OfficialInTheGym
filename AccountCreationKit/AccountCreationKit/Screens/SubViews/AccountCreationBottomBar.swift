//
//  AccountCreationBottomBar.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// The single forward action, full width at the bottom — the shape every MyDay builder screen uses
/// for "Continue". Back lives in the top bar, so there is one thing to press down here.
///
/// The disabled styling is the one `SessionSetDetailOverlay`'s log button established:
/// `Color.secondary` on `tertiarySystemFill`, with `.easeInOut(0.15)` on the flag.
struct AccountCreationBottomBar: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    private var isEnabled: Bool { viewModel.canAdvance }

    var body: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 10) {
                if let error = viewModel.creationError {
                    AccountCreationErrorBanner(message: error)
                }

                Button {
                    viewModel.advance()
                } label: {
                    Text(viewModel.step.actionTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isEnabled ? Color.white : Color.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isEnabled ? Color.darkColor : Color(UIColor.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .disabled(!isEnabled)
                .animation(.easeInOut(duration: 0.15), value: isEnabled)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    AccountCreationBottomBar(viewModel: .preview)
}
