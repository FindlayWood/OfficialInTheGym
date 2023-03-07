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
    var dismissAction: () -> ()
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if SubscriptionManager.shared.isSubscribed {
                        SubscribedView()
                        Button {
                            
                        } label: {
                            Text("Cancel Subscription")
                                .foregroundColor(Color(.premiumColour))
                        }.padding()
                    } else {
                        Text("Sign up for a premium account and gain access to awesome features and power yourself into an elite athlete.")
                            .font(.body.weight(.medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.bottom)
                        Spacer()
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
                                            .foregroundColor(viewModel.selectedPackage == package ? Color(.darkColour) : .primary)
                                        Text(package.storeProduct.localizedPriceString)
                                            .font(.subheadline)
                                            .foregroundColor(viewModel.selectedPackage == package ? Color(.darkColour) : .primary)
                                        if viewModel.selectedPackage == package {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.title)
                                                .foregroundColor(viewModel.selectedPackage == package ? Color(.darkColour) : Color(.premiumColour))
                                        } else {
                                            Image(systemName: "circle")
                                                .font(.title)
                                                .foregroundColor(viewModel.selectedPackage == package ? .white : Color(.premiumColour))
                                        }
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(viewModel.selectedPackage == package ? Color(.premiumColour) : Color(.systemBackground))
                                    .cornerRadius(8)
                                    .shadow(radius: viewModel.selectedPackage == package ? 0 : 4)
                                    .overlay(RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.premiumColour), lineWidth: 2))
                                    .padding()
                                }
                                .disabled(viewModel.isLoading)
                            }
                        }
                        .padding(.horizontal)
                        if viewModel.isLoading {
                            VStack {
                                ProgressView()
                                    .tint(Color(.darkColour))
                                    .padding()
                            }
                            .background(Color(.premiumColour))
                            .clipShape(Capsule())
                        } else {
                            Button {
                                Task {
                                    await viewModel.subscribeAction()
                                }
                            } label: {
                                Text("Subscribe")
                                    .padding()
                                    .font(.headline)
                                    .foregroundColor(Color(.darkColour))
                                    .frame(maxWidth: .infinity)
                                    .background(Color(.premiumColour))
                                    .clipShape(Capsule())
                                    .shadow(radius: 4)
                            }
                        }
                        
                        Text("Recurring bill, cancel anytime, \n Your payment will be charged to your iTunes account and your subscription will automatically renew for the same package length at the same price until you cancel it. Cancel anytime from settings -> subscriptions.")
                            .font(.footnote)
                            .foregroundColor(Color(.secondaryLabel))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    
                }
                .animation(.easeInOut, value: viewModel.isLoading)
                .navigationTitle("Premium")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity)
                .padding()
                
                .task {
                    await viewModel.fetchIAPOfferings()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            dismissAction()
                        } label: {
                            Text("Dismiss")
                                .fontWeight(.bold)
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
            }
            .background(
                LinearGradient(colors: [Color(.secondarySystemBackground), Color(.secondarySystemBackground), Color(.premiumColour)], startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
        }
    }
}

struct SubscribedView: View {
    var body: some View {
        VStack {
            Text("Subscribed")
                .font(.title.bold())
                .foregroundColor(.primary)
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.green)
                .padding()
            Text("You have subscribed to InTheGym premium! You have full access to all our awesome features. Check out the performance center and recorded and watch some clips! Thanks for subscribing to InTheGym premium.")
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
