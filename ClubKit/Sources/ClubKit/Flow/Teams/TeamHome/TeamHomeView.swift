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
//            Section {
//                Button {
//                    viewModel.selectedAction?(.defaultLineup)
//                } label: {
//                    HStack {
//                        Image(systemName: "text.badge.star")
//                        Text("Default Lineup")
//                    }
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                }
//            } header: {
//                Text("Lineups")
//            }
        }
    }
}

struct TeamHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TeamHomeView(viewModel: TeamHomeViewModel(team: .example))
    }
}
