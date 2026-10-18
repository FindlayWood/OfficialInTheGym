//
//  PlayerProfileMoreView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PlayerProfileMoreView: View {
    
    @ObservedObject var viewModel: PlayerProfileMoreViewModel
    
    var body: some View {
        
        Form {
            Section {
                HStack {
                    Image(uiImage: UIImage.legacyIcon("person.text.rectangle.fill"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.displayName)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UIImage.legacyIcon("at"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.username)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UIImage.legacyIcon("envelope.open.fill"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.email)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
//                HStack {
//                    Image(uiImage: UserDefaults.currentUser.accountType == .coach ? UIImage.legacyIcon("person.badge.shield.checkmark.fill") : UIImage.legacyIcon("figure.run"))
//                        .resizable()
//                        .frame(width: 30, height: 30)
//                        .cornerRadius(4)
//                    Text(UserDefaults.currentUser.accountType == .coach ? "Coach Account" : "Player Account")
//                        .fontWeight(.semibold)
//                        .foregroundColor(.primary)
//                }
                HStack {
                    Image(uiImage: UIImage.legacyIcon("hammer.fill"))
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(viewModel.getAccountCreated())
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                Button {
                    viewModel.action(.editProfile)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage.legacyIcon("pencil"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Edit Profile")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("My Account")
            }
            Section {
                Button {
                    viewModel.action(.subscription)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(Color(.premiumColour))
                            .cornerRadius(4)
                        Text(viewModel.subscriptionType)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("Subscription")
            }
//            Section {
//                Button {
//                    viewModel.action(.measurements)
//                } label: {
//                    HStack(spacing: 16) {
//                        Image(uiImage: UIImage.legacyIcon("ruler.fill"))
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .cornerRadius(4)
//                        Text("My Measurments")
//                            .fontWeight(.bold)
//                            .foregroundColor(.primary)
//                    }
//                }
//            } header: {
//                Text("My Measurements")
//            }
//            Section {
//                Button {
//                    viewModel.action(.myCoaches)
//                } label: {
//                    HStack(spacing: 16) {
//                        Image(uiImage: UIImage.legacyIcon("person.badge.shield.checkmark.fill"))
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .cornerRadius(4)
//                        Text("My Coaches")
//                            .fontWeight(.bold)
//                            .foregroundColor(.primary)
//                    }
//                }
//                Button {
//                    viewModel.action(.requests)
//                } label: {
//                    HStack(spacing: 16) {
//                        Image(uiImage: UIImage.legacyIcon("figure.strengthtraining.functional"))
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .cornerRadius(4)
//                        Text("Requests")
//                            .fontWeight(.bold)
//                            .foregroundColor(.primary)
//                    }
//                }
//            } header: {
//                Text("Coaches")
//            }
            
            Section {
                Button {
                    viewModel.action(.exerciseStats)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage.legacyIcon("list.clipboard.fill"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Exercise Stats")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    viewModel.action(.workoutStats)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage.legacyIcon("chart.line.uptrend.xyaxis"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Workout Stats")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    viewModel.action(.performanceMonitor)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage.legacyIcon("waveform.path.ecg"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Performance Center")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("Stats")
            }
            
            Section {
                Button {
                    viewModel.action(.settings)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage.legacyIcon("gearshape.fill"))
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Settings")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("More")
            }
        }
        .onAppear {
            viewModel.getProfileImage()
        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct PlayerProfileMoreView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileMoreView(viewModel: PlayerProfileMoreViewModel(purchaseManager: PreviewPurchaseManager()))
    }
}
