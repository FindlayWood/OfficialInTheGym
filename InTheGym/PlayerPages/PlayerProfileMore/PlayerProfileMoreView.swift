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
                    Image(uiImage: UIImage(named: "name_icon")!)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.firstName + " " + UserDefaults.currentUser.lastName)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UIImage(named: "at_icon")!)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.username)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UIImage(named: "email2_icon")!)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.email)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UserDefaults.currentUser.admin ? UIImage(named: "coach_icon")! : UIImage(named: "player_icon")!)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(UserDefaults.currentUser.admin ? "Coach Account" : "Player Account")
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                HStack {
                    Image(uiImage: UIImage(named: "hammer_icon")!)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .cornerRadius(4)
                    Text(viewModel.getAccountCreated())
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            } header: {
                VStack(alignment: .center) {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(40)
                            .clipShape(Circle())
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(40)
                            .clipShape(Circle())
                        
                    }
                    
                    Button {
                        
                    } label: {
                        Text("edit")
                    }

                    Text(UserDefaults.currentUser.profileBio ?? "Profile Bio")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                }
                .frame(maxWidth: .infinity)
            }
            
            Section {
                Button {
                    viewModel.action(.myCoaches)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "coach_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("My Coaches")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    viewModel.action(.requests)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "trainer_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Requests")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("Coaches")
            }
            
            Section {
                Button {
                    viewModel.action(.exerciseStats)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "clipboard_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Exercise Stats")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "linechart_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Workout Stats")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("Stats")
            }
            
            Section {
                Button {
                    viewModel.action(.measureJump)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "jump_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Measure Jump")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    viewModel.action(.breathWork)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "breath_icon")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Breath Work")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("Premium Features")
            }
            
            Section {
                Button {
                    viewModel.action(.settings)
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "settings_icon")!)
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
    }
}

struct PlayerProfileMoreView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileMoreView(viewModel: PlayerProfileMoreViewModel())
    }
}
