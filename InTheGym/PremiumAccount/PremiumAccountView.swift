//
//  PremiumAccountView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import SwiftUI
import RevenueCat

struct PremiumAccountView: View {
    @ObservedObject var viewModel: PremiumAccountViewModel

    @State private var selectedProduct: DisplayAndPurchaseProduct?
    
    var next: (() -> ())?
    
    var body: some View {
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
            
            if viewModel.isLoading {
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

struct SubscribedView: View {
    var body: some View {
        VStack {
            VStack {
                Text("Subscribed")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                Image(systemName: "checkmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.green)
                    .padding()
                Text("You have subscribed to InTheGym premium! You have full access to all our awesome features. Check out the performance center, record and watch some clips! Thanks for subscribing to InTheGym premium.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(Color(.white))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.premiumColour), lineWidth: 1)
            )
            Text("If you would like to cancel your subscription, you must do this through Apple.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

struct SubscriptionFeatureView: View {
    
    var imageName: String
    var title: String
    var message: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.premiumColour), lineWidth: 2)
        )
    }
}
