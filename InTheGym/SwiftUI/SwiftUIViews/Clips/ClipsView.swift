//
//  ClipsView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 27/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct ClipsView: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    
    // MARK: - View Model
    @StateObject var viewModel = ClipsViewModel()
    
    // MARK: - Callback
    var selection: (ClipModel) -> ()
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $viewModel.searchText, placeholder: "search clips...")
                ScrollView {
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())]) {
                        ForEach(viewModel.clips, id: \.id) { model in
                            Button {
                                selection(model)
                            } label: {
                                ClipGridView(clipModel: model)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Clips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("dismiss")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkColour))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
            .task {
                await viewModel.fetchClips()
            }
        }
    }
}
