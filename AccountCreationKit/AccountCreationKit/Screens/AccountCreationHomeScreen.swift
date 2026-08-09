//
//  AccountCreationHomeScreen.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountCreationHomeScreen: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    /// The number of steps in the flow. The progress bar and the step controls both read it, so it
    /// lives in one place rather than as a `7` in each.
    static let stepCount: Int = 7

    var body: some View {
        ZStack {
            VStack {
                AccountCreationProgressBar(page: $viewModel.page)

                TabView(selection: $viewModel.page) {
                    WelcomeStepView()
                        .tag(0)
                    UsernameStepView(viewModel: viewModel)
                        .tag(1)
                    DisplayNameStepView(viewModel: viewModel)
                        .tag(2)
                    BioStepView(viewModel: viewModel)
                        .tag(3)
                    AccountTypeStepView(viewModel: viewModel)
                        .tag(4)
                    ProfilePictureStepView(viewModel: viewModel)
                        .tag(5)
                    ProfileSummaryStepView(viewModel: viewModel)
                        .tag(6)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                AccountCreationStepControls(viewModel: viewModel)
            }

            if viewModel.uploading {
                AccountCreationLoadingView()
            }
        }
    }
}

#Preview {
    AccountCreationHomeScreen(viewModel: .preview)
}
