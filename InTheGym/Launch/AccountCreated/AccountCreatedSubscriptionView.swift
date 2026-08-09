//
//  AccountCreatedSubscriptionView.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2024.
//  Copyright © 2024 FindlayWood. All rights reserved.
//

import StoreKit
import SwiftUI

struct AccountCreatedSubscriptionView: View {

    @ObservedObject var viewModel: AccountCreatedViewModel

    @State private var selectedProduct: DisplayAndPurchaseProduct?

    var next: (() -> ())?

    var body: some View {
        if viewModel.success {
            PurchaseSuccessSubview(action: { next?() })
        } else {
            paywall
        }
    }

    // MARK: - Paywall

    private var paywall: some View {
        VStack(spacing: 0) {
            header

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    Text("Gain access to the performance center including all workout stats and record and watch video clips with INTHEGYM pro.")
                        .font(.system(size: 17))
                        .foregroundStyle(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 10) {
                        ForEach(viewModel.products, id: \.id) { product in
                            SubscriptionProductRow(
                                product: product,
                                isSelected: selectedProduct?.id == product.id,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedProduct = product
                                    }
                                }
                            )
                        }
                    }

                    SubscriptionFeatureList()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }

            bottomBar
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .task {
            await viewModel.loadProducts()
            selectedProduct = viewModel.products.first
        }
    }

    private var header: some View {
        HStack(alignment: .lastTextBaseline, spacing: 6) {
            Text("INTHEGYM")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Color(.darkColour))
            Text("pro")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color(.premiumColour))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Bottom Bar

    /// **"Not Now" is always here.** It used to live in an `else` branch that an error or a stuck
    /// `isLoading` removed entirely, so a failed purchase could leave the user on a paywall with no
    /// way past it and no way into the app.
    private var bottomBar: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 12) {
                if let error = viewModel.error {
                    PurchaseErrorBanner(message: error.description) {
                        retry(after: error)
                    }
                }

                if viewModel.isLoading {
                    CircularLoader(size: 28, lineWidth: 4)
                        .frame(height: 52)
                } else if let selectedProduct {
                    Button {
                        Task { await viewModel.purchaseProduct(selectedProduct) }
                    } label: {
                        Text("Purchase pro")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(.premiumColour))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }

                HStack(spacing: 24) {
                    Button {
                        Task { await viewModel.restorePurchase() }
                    } label: {
                        Text("Restore Purchases")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }

                    Button {
                        next?()
                    } label: {
                        Text("Not Now")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color(.darkColour))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color(.systemBackground))
    }

    /// Loading products is the only failure with something to retry — the rest just need clearing so
    /// the user can press the button again.
    private func retry(after error: PurchaseError) {
        viewModel.error = nil
        guard error == .loadingProducts else { return }
        Task {
            await viewModel.loadProducts()
            selectedProduct = viewModel.products.first
        }
    }
}

#Preview {
    AccountCreatedSubscriptionView(
        viewModel: AccountCreatedViewModel(purchaseManager: PreviewPurchaseManager())
    )
}
