//
//  AccountCreationProgressBar.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// One segment per step, filled up to the current one.
///
/// **Tappable backwards only.** Every segment used to be tappable in both directions, so a user on
/// step one could jump straight to the summary and find themselves stuck behind a disabled button
/// with nothing saying which answer was missing. Going back to something already answered is safe
/// and useful; jumping forward past a question is neither.
struct AccountCreationProgressBar: View {

    @Binding var step: AccountCreationStep

    var body: some View {
        HStack(spacing: 6) {
            ForEach(AccountCreationStep.allCases) { candidate in
                Capsule()
                    .fill(candidate.rawValue <= step.rawValue ? Color.darkColor : Color(.tertiarySystemFill))
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard candidate.rawValue < step.rawValue else { return }
                        withAnimation(.easeInOut(duration: 0.25)) { step = candidate }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: step)
    }
}

#Preview {
    AccountCreationProgressBar(step: .constant(.details))
        .padding()
}
