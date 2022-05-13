//
//  SettingsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("App Version")
                        .fontWeight(.bold)
                    Spacer()
                    Text(Constants.appVersion!)
                }
                
            } footer: {
                Text("Keep the app up to date for all the lastest features.")
            }
            
            Section {
                Button {
                    viewModel.about()
                } label: {
                    Text("About")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Button {
                    viewModel.icons()
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "icons8_logo")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Icons")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            } header: {
                Text("About")
            } footer: {
                Text("Our awesome icons are provided by Icons8. They have a great service for icons, check them out above.")
            }
            
            Section {
                Button {
                    viewModel.instagram()
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "instagram_logo")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Instagram")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                Button {
                    viewModel.website()
                } label: {
                    HStack(spacing: 16) {
                        Image(uiImage: UIImage(named: "inthegym_icon3")!)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                        Text("Website")
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    
                }
            } header: {
                Text("Contact Info")
            } footer: {
                Text("Send us an email at officialinthegym@gmail.com")
            }
            
            Section {
                Button {
                    viewModel.resetPasswordTapped()
                } label: {
                    Text("Reset Password")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            } footer: {
                Text("If you wish to reset your password we will send you an email with instructions on how to do so.")
            }
            
            Section {
                Button {
                    viewModel.logoutTapped()
                } label: {
                    Text("Logout")
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
            } footer: {
                Text("Logging out from the app will mean you will not be automatically logged in when you open the app until you log in again.")
            }

        }
        .edgesIgnoringSafeArea(.top)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
            .preferredColorScheme(.dark)
    }
}
