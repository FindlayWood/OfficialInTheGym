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
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "")
                    Text("Players")
                }
                .foregroundColor(.primary)
            }
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "")
                    Text("Default Lineup")
                }
                .foregroundColor(.primary)
            }
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "")
                    Text("Lineups")
                }
                .foregroundColor(.primary)
            }
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "")
                    Text("Fixtures")
                }
                .foregroundColor(.primary)
            }
            Button {
                
            } label: {
                HStack {
                    Image(systemName: "")
                    Text("Results")
                }
                .foregroundColor(.primary)
            }
        }
    }
}

struct TeamHomeView_Previews: PreviewProvider {
    static var previews: some View {
        TeamHomeView(viewModel: TeamHomeViewModel())
    }
}
