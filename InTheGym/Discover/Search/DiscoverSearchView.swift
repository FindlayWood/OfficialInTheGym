//
//  DiscoverSearchView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct DiscoverSearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var action: (Users) -> ()
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                DiscoverSearchBar(searchText: $viewModel.searchText, placeholder: "search...")
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))

            List {
                if viewModel.searchedUsers.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            ZStack(alignment: .bottomTrailing) {
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color(.darkColour))
                            }
                            .padding()
                            Text("Search for other users by their username.")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(viewModel.searchedUsers, id: \.uid) { model in
                        Button {
                            action(model)
                        } label: {
                            UserRow(user: model)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.initSubscribers()
        }
    }
}

struct DiscoverSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverSearchView(viewModel: SearchViewModel(), action: {_ in })
    }
}
