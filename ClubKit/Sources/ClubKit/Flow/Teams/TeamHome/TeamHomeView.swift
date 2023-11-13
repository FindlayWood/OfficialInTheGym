//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 27/05/2023.
//

import SwiftUI

struct TeamHomeView: View {
    
    @ObservedObject var viewModel: TeamHomeViewModel
    
    var body: some View {
        List {
            Section {
                Button {
                    viewModel.selectedAction?(.players)
                } label: {
                    HStack {
                        Image(systemName: "person")
                        Text("Players")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Players")
            }
            Section {
                Button {
                    viewModel.selectedAction?(.defaultLineup)
                } label: {
                    HStack {
                        Image(systemName: "text.badge.star")
                        Text("Default Lineup")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal")
                        Text("Lineups")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Lineups")
            }
            Section {
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Fixtures")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        Text("Results")
                    }
                    .font(.headline)
                    .foregroundColor(.primary)
                }
            } header: {
                Text("Results")
            }
        }
    }
}

struct TeamHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TeamHomeView(viewModel: TeamHomeViewModel(team: .example))
    }
}
