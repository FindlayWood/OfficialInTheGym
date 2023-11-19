//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import SwiftUI

struct TeamDefaultLineupView: View {
    
    @ObservedObject var viewModel: TeamDefaultLineupViewModel
    
    var body: some View {
        if viewModel.isLoading {
            VStack {
                Image(systemName: "network")
                    .font(.largeTitle)
                    .foregroundColor(Color(.darkColour))
                Text("Loading Lineup")
                    .font(.title.bold())
                    .foregroundColor(Color(.darkColour))
                Text("Wait 1 second, we are just loading your lineup!")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
        } else if viewModel.isUploading {
            VStack {
                Image(systemName: "network")
                    .font(.largeTitle)
                    .foregroundColor(Color(.darkColour))
                Text("Uploading")
                    .font(.title.bold())
                    .foregroundColor(Color(.darkColour))
                Text("Wait 1 second, we are just uploading your lineup!")
                    .font(.footnote.bold())
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                ProgressView()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
        } else {
            List {
                if viewModel.team.defaultLineup == nil {
                    Section {
                        Text("This team has no Default Lineup. Add it now!")
                    }
                }
                Section {
                    ForEach(0..<viewModel.team.sport.starters, id: \.self) { number in
                        HStack {
                            Text("\(number + 1).")
                            if let model = viewModel.checkNumber(number + 1) {
                                Text(model.playerModel.displayName)
                                Spacer()
                                if viewModel.isEditing {
                                    Button {
                                        viewModel.removePlayer(number + 1)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                Spacer()
                                if viewModel.isEditing {
                                    Button {
                                        viewModel.addNewPlayer?(number + 1)
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(Color(.darkColour))
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Starters")
                }
                
                Section {
                    ForEach(0..<viewModel.team.sport.subs, id: \.self) { number in
                        HStack {
                            Text("\(number + viewModel.team.sport.starters + 1).")
                            if let model = viewModel.checkNumber(viewModel.team.sport.starters + number + 1) {
                                Text(model.playerModel.displayName)
                                Spacer()
                                if viewModel.isEditing {
                                    Button {
                                        viewModel.removePlayer(viewModel.team.sport.starters + number + 1)
                                    } label: {
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.red)
                                    }
                                }
                            } else {
                                Spacer()
                                if viewModel.isEditing {
                                    Button {
                                        viewModel.addNewPlayer?(viewModel.team.sport.starters + number + 1)
                                    } label: {
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(Color(.darkColour))
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("Subs")
                }
                
                if viewModel.isEditing {
                    Section {
                        Button {
                            Task {
                                await viewModel.uploadAction()
                            }
                            viewModel.isEditing = false
                        } label: {
                            Text("Submit Lineup")
                                .padding()
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color(.darkColour))
                                .clipShape(Capsule())
                                .shadow(radius: 2, y: 2)
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
    }
}

struct TeamDefaultLineupView_Previews: PreviewProvider {
    class PreviewLineupLoader: LineupLoader {
        func loadAllLineups(for teamID: String, in clubID: String) async throws -> [RemoteLineupModel] { return [] }
        func loadAllLineupPlayerModels(with lineupID: String, for teamID: String, in clubID: String) async throws -> [RemoteLineupPlayerModel] { return [] }
    }
    class PreviewPlayerLoader: PlayerLoader {
        func loadAllPlayers(for teamID: String, in clubID: String) async throws -> [RemotePlayerModel] { return [] }
        func loadPlayer(with uid: String, from clubID: String) async throws -> RemotePlayerModel { return .example }
        func uploadNewPlayer(_ model: RemotePlayerModel, to teams: [String]) async throws {}
        func loadAllPlayers(for clubID: String) async throws -> [RemotePlayerModel] { return [] }
    }
    class PreviewUploadService: UploadLineupService {
        func uploadLineup(with data: UploadLineupModel) async -> Result<UploadLineupModel, RemoteUploadLineupService.Error> { return .failure(.failed) }
    }
    static var previews: some View {
        TeamDefaultLineupView(viewModel: TeamDefaultLineupViewModel(team: .example, lineupLoader: PreviewLineupLoader(), playerLoader: PreviewPlayerLoader(), lineupUploadService: PreviewUploadService()))
    }
}
