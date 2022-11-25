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
            SearchBar(searchText: $viewModel.searchText, placeholder: "Search for users")
            List {
                if viewModel.searchedUsers.isEmpty {
                    HStack {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "magnifyingglass")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour))
                            Text("Search for other users by their username.")
                                .font(.body.weight(.semibold))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
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
            .listStyle(.plain)
            .background(Color(.secondarySystemBackground))
        }
        .background(Color(.systemBackground))
    }
}

struct DiscoverSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverSearchView(viewModel: SearchViewModel(), action: {_ in })
    }
}
