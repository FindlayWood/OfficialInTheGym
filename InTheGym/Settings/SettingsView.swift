//
//  SettingsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text("4.4")
                }
                
            } footer: {
                Text("Keep the app up to date for all the lastest features.")
            }
            
            Section {
                Text("About")
                Text("Feedback")
                Text("Icons")
            } header: {
                Text("About")
            } footer: {
                Text("Our awesome icons are provided by Icons8. They have a great service for icons, check them out above.")
            }
            
            Section {
                Text("Instagram")
                Text("Website")
                Text("Contact Us")
            } header: {
                Text("Contact Info")
            } footer: {
                Text("Send us an email at officialinthegym@gmail.com")
            }
            
            Section {
                Text("Reset Password")
            } footer: {
                Text("If you wish to reset your password we will send you an email with instructions on how to do so.")
            }
            
            Section {
                Button {
                    
                } label: {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            } footer: {
                Text("Logging out from the app will mean you will not be automatically logged in when you open the app until you log in again.")
            }

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
