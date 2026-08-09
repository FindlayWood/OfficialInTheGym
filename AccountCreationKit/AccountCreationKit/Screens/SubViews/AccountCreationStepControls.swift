//
//  AccountCreationStepControls.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountCreationStepControls: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    private var isFirstStep: Bool { viewModel.page == 0 }
    private var isLastStep: Bool { viewModel.page == AccountCreationHomeScreen.stepCount - 1 }

    var body: some View {
        HStack {
            if !isFirstStep {
                Button {
                    viewModel.page -= 1
                } label: {
                    chevron("chevron.left")
                }
            }

            Spacer()

            if isLastStep {
                Button {
                    viewModel.createAccount()
                } label: {
                    Text("Create Account")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(Color.darkColor.opacity(viewModel.canCreateAccount ? 1 : 0.3))
                        .clipShape(Capsule())
                        .shadow(radius: viewModel.canCreateAccount ? 4 : 0)
                }
                .disabled(!viewModel.canCreateAccount)
            } else if isFirstStep {
                VStack {
                    Button {
                        viewModel.page += 1
                    } label: {
                        Text("Get Started")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.darkColor)
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    Button {
                        viewModel.signOutAction()
                    } label: {
                        Text("Sign Out")
                            .font(.footnote.weight(.medium))
                            .foregroundColor(.red)
                    }
                }
            } else {
                Button {
                    viewModel.page += 1
                } label: {
                    chevron("chevron.right")
                }
            }
        }
        .padding([.horizontal, .bottom])
    }

    private func chevron(_ systemName: String) -> some View {
        ZStack {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.darkColor)
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    AccountCreationStepControls(viewModel: .preview)
}
