//
//  File.swift
//  
//
//  Created by Findlay Wood on 25/11/2023.
//

import Foundation

class CreateStaffViewModel: ObservableObject {
    
    // MARK: - Dependencies
    var clubModel: RemoteClubModel
    var teamLoader: TeamLoader
    var creationService: StaffCreationService
    // MARK: - Loading Variables
    @Published var isLoadingTeams: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    // MARK: - New Model Variables
    @Published var displayName: String = ""
    @Published var teams: [RemoteTeamModel] = []
    @Published var selectedTeams: [RemoteTeamModel] = []
    @Published var role: StaffRoles = .coach
    @Published var isAdmin: Bool = false
    
    init(clubModel: RemoteClubModel, teamLoader: TeamLoader, creationService: StaffCreationService) {
        self.clubModel = clubModel
        self.teamLoader = teamLoader
        self.creationService = creationService
    }
    
    @MainActor
    func loadTeams() {
        isLoadingTeams = true
        Task {
            do {
                teams = try await teamLoader.loadAllTeams(for: clubModel.id)
                isLoadingTeams = false
            } catch {
                print(String(describing: error))
                isLoadingTeams = false
            }
        }
    }
    
    @MainActor
    func toggleSelectedTeam(_ model: RemoteTeamModel) {
        if let index = selectedTeams.firstIndex(where: { $0.id == model.id }) {
            selectedTeams.remove(at: index)
        } else {
            selectedTeams.append(model)
        }
    }
    
    @MainActor
    func create() async {
        isUploading = true
        let newStaffData = NewStaffData(id: UUID().uuidString, displayName: displayName, clubID: clubModel.id, role: role, teams: selectedTeams.map { $0.id }, isAdmin: isAdmin)
        let result = await creationService.createNewStaff(with: newStaffData)
        switch result {
        case .success:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.selectedTeams.removeAll()
                self.isUploading = false
                self.uploaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploaded = false
                }
            }
        case .failure(let failure):
            print(String(describing: failure))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.isUploading = false
                self.errorUploading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.errorUploading = false
                }
            }
        }
    }
    
    var buttonDisabled: Bool {
        displayName.isEmpty
    }
}
