//
//  AccountCreationStepHeader.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// Title and subtitle, identical on every step. There is no navigation bar on this flow, so the
/// large title lives in the content — the same weight `MyDayWorkoutLibraryScreen` gets from
/// `.navigationBarTitleDisplayMode(.large)`.
struct AccountCreationStepHeader: View {

    let step: AccountCreationStep

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(step.title)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            Text(step.subtitle)
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AccountCreationStepHeader(step: .details)
        .padding()
}
