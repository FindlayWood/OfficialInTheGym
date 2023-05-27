//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 24/05/2023.
//

import SwiftUI

struct PlayersView: View {
    
    @ObservedObject var viewModel: PlayersViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                VStack {
                    Image(systemName: "network")
                        .font(.largeTitle)
                        .foregroundColor(Color(.darkColour))
                    Text("Loading Players")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("Wait 1 second, we are just loading your players!")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                if viewModel.players.isEmpty {
                    VStack {
                        ZStack {
                            Image(systemName: "person.3.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "nosign")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red.opacity(0.5))
                        }
                        Text("No Players")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("This club currently has no players. You can create a team for this club. Once you have created a team it will appear here.")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(.darkColour).opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                } else {
                    SearchBar(searchText: $viewModel.searchText, placeholder: "search players...")
                        .background(Capsule()
                            .foregroundColor(Color(.systemBackground)))
                    HStack {
                        Button("Sort") {}
                        Spacer()
                        Button("Filter") {}
                    }
                    .foregroundColor(.primary)
                    .padding([.top, .leading, .trailing])
                    
                    List {
                        ForEach(viewModel.players) { model in
                            PlayerRow(model: model)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.load()
        }

    }
}

struct PlayersView_Previews: PreviewProvider {
    class PreviewPlayerLoader: PlayerLoader {
        func uploadNewPlayer(_ model: RemotePlayerModel) async throws {}
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
    }
    static var previews: some View {
        PlayersView(viewModel: PlayersViewModel(clubModel: .example, playerLoader: PreviewPlayerLoader()))
    }
}
