//
//  File.swift
//  
//
//  Created by Findlay-Personal on 21/05/2023.
//

import Foundation

class TeamsViewModel: ObservableObject {
    
    @Published var errorLoading: Error?
    @Published var teams: [RemoteTeamModel] = []
    @Published var isLoading: Bool = false
    
    var clubModel: RemoteClubModel
    var teamLoader: TeamLoader
    
    init(clubModel: RemoteClubModel, teamLoader: TeamLoader) {
        self.clubModel = clubModel
        self.teamLoader = teamLoader
    }
    
    @MainActor
    func load() async {
        isLoading = true
        do {
            teams = try await teamLoader.loadAllTeams(for: clubModel.id)
            isLoading = false
        } catch {
            errorLoading = error
            print(String(describing: error))
            isLoading = false
        }
    }
    
}
