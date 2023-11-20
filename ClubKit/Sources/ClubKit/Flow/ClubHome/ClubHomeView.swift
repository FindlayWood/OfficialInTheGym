//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

struct ClubHomeView: View {
    
    @ObservedObject var viewModel: ClubHomeViewModel
    
    var body: some View {
        List {
            
            Section {
                Button {
                    viewModel.teamsAction()
                } label: {
                    HStack {
                        Image(systemName: "shield")
                        Text("Teams")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                
                Button {
                    viewModel.groupsAction()
                } label: {
                    HStack {
                        Image(systemName: "person.3.sequence.fill")
                        Text("Workout Groups")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Schedule")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            }
            
            Section {
                Button {
                    viewModel.playersAction()
                } label: {
                    HStack {
                        Image(systemName: "person")
                        Text("Players")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "person.crop.artframe")
                        Text("Staff")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            } header: {
                Text("People")
            }
            
            Section {
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Settings")
            }
        }
    }
}

struct ClubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ClubHomeView(viewModel: ClubHomeViewModel(clubModel: .example))
    }
}
