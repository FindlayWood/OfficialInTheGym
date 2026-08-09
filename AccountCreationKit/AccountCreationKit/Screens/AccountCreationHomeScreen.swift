//
//  AccountCreationHomeScreen.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountCreationHomeScreen: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                AccountCreationTopBar(
                    showsBack: viewModel.step.previous != nil,
                    showsSignOut: viewModel.step == .details,
                    onBack: { withAnimation(.easeInOut(duration: 0.25)) { viewModel.goBack() } },
                    onSignOut: viewModel.signOutAction
                )

                AccountCreationProgressBar(step: $viewModel.step)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)

                TabView(selection: $viewModel.step) {
                    DetailsStepView(viewModel: viewModel)
                        .tag(AccountCreationStep.details)
                    ProfileStepView(viewModel: viewModel)
                        .tag(AccountCreationStep.profile)
                    BodyStepView(viewModel: viewModel)
                        .tag(AccountCreationStep.body)
                    ReviewStepView(viewModel: viewModel)
                        .tag(AccountCreationStep.review)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                AccountCreationBottomBar(viewModel: viewModel)
            }

            if viewModel.uploading {
                AccountCreationLoadingView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.step)
    }
}

#Preview {
    AccountCreationHomeScreen(viewModel: .preview)
}
