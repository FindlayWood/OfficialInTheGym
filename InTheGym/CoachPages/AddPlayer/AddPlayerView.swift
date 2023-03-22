//
//  AddPlayerView.swift
//  InTheGym
//
//  Created by Findlay Wood on 31/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SearchPlayerView: View {
    
    @ObservedObject var viewModel: AddPlayerViewModel
    
    var pressedRow: (CoachRequestCellModel) -> ()
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                DiscoverSearchBar(searchText: $viewModel.searchText, placeholder: "search...")
            }
            .padding(.horizontal)
            .background(Color(.systemBackground))
            
            List {
                if viewModel.cellModels.isEmpty {
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
                    ForEach(viewModel.cellModels, id: \.user.uid) { model in
                        Button {
                            pressedRow(model)
                        } label: {
                            CoachRequestRow(cellModel: model)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            viewModel.initSubscriptions()
        }
    }
}
