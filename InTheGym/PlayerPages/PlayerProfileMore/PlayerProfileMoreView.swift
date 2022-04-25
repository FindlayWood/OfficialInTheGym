//
//  PlayerProfileMoreView.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/04/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PlayerProfileMoreView: View {
    var body: some View {

        
        Form {
            Section {
                Text("My Coaches")
                Text("Requests")
            } header: {
                VStack {
                    Image("")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(25)
                        .background(Color.gray)
                    Button {
                        
                    } label: {
                        Text("edit")
                    }

                    Text("My Profile")
                        .padding()
                    Button {
                        print("edit")
                    } label: {
                        Text("Edit")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding()
                    }
                }
            }
            
            Section {
                Text("Exercise Stats")
                Text("Workout Stats")
            } header: {
                Text("Stats")
            }
            
            Section {
                Text("Measure Jump")
                Text("Breath Work")
            } header: {
                Text("Premium Features")
            }
            
            Section {
                Text("Settings")
            } header: {
                Text("More")
            }
        }
    }
}

struct PlayerProfileMoreView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerProfileMoreView()
    }
}
