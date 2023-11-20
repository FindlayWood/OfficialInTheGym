//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 29/05/2023.
//

import SwiftUI

struct PlayerSelectionView: View {
    
    @ObservedObject var viewModel: PlayerSelectionViewModel
    
    var selectedPlayers: [RemotePlayerModel] = []
    var disabledSelectedPlayers: Bool = true
    
    var body: some View {
        VStack {
            SearchBar(searchText: $viewModel.searchText, placeholder: "search players...")
                .background(Capsule()
                    .foregroundColor(Color(.systemBackground)))
            List {
                Section {
                    ForEach(viewModel.searchedPlayers) { model in
                        PlayerRow(model: model) {
                            
                        }
                    }
                } header: {
                    Text("Players")
                }
            }
        }
    }
}

struct PlayerSelectionView_Previews: PreviewProvider {
    private class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel { return .example }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
    }
    static var previews: some View {
        PlayerSelectionView(viewModel: PlayerSelectionViewModel(clubModel: .example, playerLoader: PreviewPlayerLoader()))
    }
}
