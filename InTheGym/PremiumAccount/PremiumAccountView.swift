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
            HStack {
                Image("clip_icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("Clips")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Record and upload clips.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            HStack {
                Image("monitor_icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("Performance Center")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Gain access to the performance center.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            HStack {
                ForEach(viewModel.subscriptionPackages) { package in
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
                            Button {
                                viewModel.selectedPackage = package
                            } label: {
                                Image(systemName: "circle")
                                    .font(.title)
                                    .foregroundColor(viewModel.selectedPackage == package ? .white : Color(.darkColour))
                            }
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
            }
            .padding(.horizontal)
            Button {
                
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
            Text("Recurring bill, cancel anytime, \n Your payment will be charged to your iTunes account and your subscription will automatically renew for the same package length at the same price until you cancel it. Cancel anytime from settings -> subscriptions.")
                .font(.footnote)
                .foregroundColor(Color(.tertiaryLabel))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
        .task {
            await viewModel.fetchIAPOfferings()
        }
    }
}
