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
            PurchaseSuccessSubview(action: {
                next?()
            })
        } else {
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text("INTHEGYM")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color(.darkColour))
                    Text("pro")
                        .font(.title.bold())
                        .foregroundStyle(Color(.premiumColour))
                }
                ZStack(alignment: .bottom) {
                    
                    ScrollView {
                        VStack {
                            
                            Text("Gain access to the performance center including all workout stats and record and watch video clips with INTHEGYM pro.")
                                .font(.title2.weight(.semibold))
                                .multilineTextAlignment(.leading)
                                .padding()
                            
                            ForEach(viewModel.products, id: \.id) { (product) in
                                if selectedProduct?.id == product.id {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.period)
                                                .font(.title2.bold())
                                                .foregroundStyle(Color.primary)
                                            HStack {
                                                Text(product.displayPrice)
                                                    .font(.headline)
                                                    .foregroundStyle(Color.primary)
                                                Text("/ \(product.perPeriod)")
                                            }
                                            
                                        }
                                        Spacer()
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color(.premiumColour))
                                    }
                                    .padding()
                                    .background {
                                        Color(.backgroundColour)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .shadow(radius: 2, y: 2)
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .inset(by: 1)
                                            .stroke(Color(.premiumColour), lineWidth: 2)
                                    }
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                                    .padding()
                                } else {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.period)
                                                .font(.title2.bold())
                                                .foregroundStyle(Color.primary)
                                            HStack {
                                                Text(product.displayPrice)
                                                    .font(.headline)
                                                    .foregroundStyle(Color.primary)
                                                Text("/ \(product.perPeriod)")
                                            }
                                            
                                        }
                                        Spacer()
                                        
                                        Image(systemName: "circle")
                                            .foregroundStyle(Color(.premiumColour))
                                    }
                                    .padding()
                                    .background {
                                        Color(.backgroundColour)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                            .shadow(radius: 2, y: 2)
                                    }
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                                    .padding()
                                }
                            }
                            
                            VStack {
                                Text("What INTHEGYM pro includes")
                                    .font(.footnote.weight(.semibold))
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Record Clips")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Watch Clips")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Individual Exercise Stats")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Vertical Jump Stats")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("CMJ stats")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Injury tracker")
                                    }
                                    HStack {
                                        Image(systemName: "checkmark")
                                            .bold()
                                            .foregroundStyle(Color.green)
                                        Text("Journal")
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 8)
                                        .inset(by: 1)
                                        .stroke(Color(.secondarySystemBackground), lineWidth: 2)
                                }
                                .padding(.horizontal)
                            }
                            .padding(.top)
                            
                            
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                    
                    if !viewModel.isLoading {
                        if let selectedProduct {
                            Button {
                                Task {
                                    await viewModel.purchaseProduct(selectedProduct)
                                }
                            } label: {
                                Text("Purchase pro")
                                    .font(.headline)
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        Color(.premiumColour)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                            .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                                    }
                            }
                            .padding()
                        }
                    }
                }
                
                if let error = viewModel.error {
                    switch error {
                    case .loadingProducts:
                        Text("Failed to load products. Please try again.")
                            .font(.system(size: 15, weight: .semibold))
                        Button {
                            viewModel.error = nil
                            Task {
                                await viewModel.loadProducts()
                                selectedProduct = viewModel.products.first
                            }
                        } label: {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color(.redColour)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                                }
                        }
                        .padding()
                    case .purchasingProduct:
                        Text("Failed to purchase.")
                            .font(.system(size: 15, weight: .semibold))
                        Button {
                            viewModel.error = nil
                        } label: {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color(.redColour)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                                }
                        }
                        .padding()
                    case .restorePurchases:
                        Text("Failed to restore purchase. Please try again")
                            .font(.system(size: 15, weight: .semibold))
                        Button {
                            viewModel.error = nil
                        } label: {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color(.redColour)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                                }
                        }
                        .padding()
                    case .handleResult:
                        Text("There was an error. Please try again.")
                            .font(.system(size: 15, weight: .semibold))
                        Button {
                            viewModel.error = nil
                        } label: {
                            Text("Try Again")
                                .font(.headline)
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color(.redColour)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                        .shadow(color: .black.opacity(0.5), radius: 2, y: 2)
                                }
                        }
                        .padding()
                    }
                } else if viewModel.isLoading {
                    CircularLoader(size: 40, lineWidth: 6)
                        .padding()
                } else {
                    Button {
                        Task {
                            await viewModel.restorePurchase()
                        }
                    } label: {
                        Text("Restore Purchases")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.primary)
                    }
                    
                    Button {
                        next?()
                    } label: {
                        Text("Not Now")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.primary)
                    }
                    .padding(.top)
                }
            }
            .background {
                Color(.systemBackground)
                    .ignoresSafeArea()
            }
            .task {
                await viewModel.loadProducts()
                selectedProduct = viewModel.products.first
            }

        }
    }
}

#Preview {
    AccountCreatedSubscriptionView(
        viewModel: AccountCreatedViewModel(purchaseManager: PreviewPurchaseManager())
    )
}

