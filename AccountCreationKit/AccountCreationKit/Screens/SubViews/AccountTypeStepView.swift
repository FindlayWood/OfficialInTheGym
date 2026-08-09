//
//  AccountTypeStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountTypeStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        VStack(alignment: .leading) {
            Text("Account Type")
                .font(.title.bold())
            ForEach(AccountType.allCases) { model in
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.title)
                            .font(.headline)
                        Text(model.message)
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: viewModel.selectedAccountType == model ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color.darkColor)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(radius: viewModel.selectedAccountType == model ? 4 : 0)
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedAccountType = model
                }
            }
            Text("Select which account type best suits you.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    AccountTypeStepView(viewModel: .preview)
}
