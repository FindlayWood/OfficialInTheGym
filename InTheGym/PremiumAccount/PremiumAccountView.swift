//
//  PremiumAccountView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import SwiftUI
import RevenueCat

struct PremiumAccountViewSwiftUI: View {
    @StateObject var viewModel = PremiumAccountViewModel()
    var body: some View {
        
        VStack {
            Spacer()
            Text("Premium Account")
                .font(.largeTitle.bold())
                .foregroundColor(Color(.darkColour))
            Text("Sign up for a premium account and gain access to awesome features and power yourself into an elite athlete.")
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
            if SubscriptionManager.shared.isSubscribed {
                SubscribedView()
            } else {
                SubscriptionFeatureView(imageName: "clip_icon", title: "Clips", message: "Record and upload clips.")
                SubscriptionFeatureView(imageName: "monitor_icon", title: "Performance Center", message: "Gain access to the performance center.")
                HStack {
                    ForEach(viewModel.subscriptionPackages) { package in
                        Button {
                            viewModel.selectedPackage = package
                        } label: {
                            VStack(spacing: 8) {
                                Text(package.storeProduct.subscriptionPeriod?.durationTitle ?? "Error")
                                    .font(.headline)
                                    .foregroundColor(viewModel.selectedPackage == package ? .white : .primary)
                                Text(package.storeProduct.localizedPriceString)
                                    .font(.subheadline)
                                    .foregroundColor(viewModel.selectedPackage == package ? .white : .primary)
                                if viewModel.selectedPackage == package {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(viewModel.selectedPackage == package ? .white : Color(.darkColour))
                                } else {
                                    Image(systemName: "circle")
                                        .font(.title)
                                        .foregroundColor(viewModel.selectedPackage == package ? .white : Color(.darkColour)) 
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.selectedPackage == package ? Color(.darkColour) : Color(.systemBackground))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.darkColour), lineWidth: 2))
                            .padding()
                        }
                        .disabled(viewModel.isLoading)
                    }
                }
                .padding(.horizontal)
                if viewModel.isLoading {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.darkColour))
                            .frame(width: 100, height: 60)
                        ProgressView()
                            .tint(.white)
                    }
                    .padding()
                } else {
                    Button {
                        Task {
                            await viewModel.subscribeAction()
                        }
                    } label: {
                        Text("Subscribe")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .cornerRadius(8)
                            .padding()
                    }
                }
                
                Text("Recurring bill, cancel anytime, \n Your payment will be charged to your iTunes account and your subscription will automatically renew for the same package length at the same price until you cancel it. Cancel anytime from settings -> subscriptions.")
                    .font(.footnote)
                    .foregroundColor(Color(.tertiaryLabel))
                    .multilineTextAlignment(.center)
                Spacer()
            }
            
        }
        .padding()
        .task {
            await viewModel.fetchIAPOfferings()
        }
    }
}

struct SubscribedView: View {
    var body: some View {
        Text("Subscribed")
            .font(.title)
            .foregroundColor(Color(.darkColour))
        Image(systemName: "checkmark.circle.fill")
            .font(.largeTitle)
            .foregroundColor(Color(.darkColour))
        Spacer()
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
    }
}
