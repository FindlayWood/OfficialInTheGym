//
//  File.swift
//  
//
//  Created by Findlay-Personal on 26/11/2023.
//

import Foundation

class QRScannerViewModel: ObservableObject {
    
    public enum QRScannerViewState {
        case scanning
        case scanError
        case loadingScan
        case gotUserProfile(UserModel)
        case loadingAdd
        case addSuccess
        case addFail
    }
    
    @Published var viewState: QRScannerViewState = .scanning
    
    // MARK: - Dependencies
    var clubModel: RemoteClubModel
    var loader: PlayerLoader
    var teamLoader: TeamLoader
    var creationService: PlayerCreationService
    // MARK: - Loading Variables
    @Published var isLoadingTeams: Bool = false
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    // MARK: - New Model Variables
    @Published var displayName: String = ""
    @Published var playerPositions: [Positions] = []
    @Published var teams: [RemoteTeamModel] = []
    @Published var selectedTeams: [RemoteTeamModel] = []
    var selectedSport: Sport
    
    let scannerService: QRScannerService
    
    init(scannerService: QRScannerService, clubModel: RemoteClubModel, loader: PlayerLoader, teamLoader: TeamLoader, creationService: PlayerCreationService) {
        self.scannerService = scannerService
        self.clubModel = clubModel
        self.loader = loader
        self.teamLoader = teamLoader
        self.selectedSport = clubModel.sport
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
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        viewState = .loadingScan
        switch result {
        case .success(let success):
            let details = success.string.components(separatedBy: QRConstants.separatingCode)
            guard details.count == 5,
                  details.first == QRConstants.startCode,
                  details.last == QRConstants.endCode else {
                viewState = .scanError
                return }
            
            let userUID = details[1]
            let displayName = details[2]
            let username = details[3]
            
            let newUserModel = UserModel(id: userUID, displayName: displayName, username: username)
            self.displayName = newUserModel.displayName
            viewState = .gotUserProfile(newUserModel)
            
            
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
    
    @MainActor
    func addPlayer(_ model: UserModel) async {
        isUploading = true
        viewState = .loadingAdd
        let qrPlayerData = AddPlayerQRData(clubID: clubModel.id, userUID: model.id, displayName: model.displayName, positions: playerPositions.map { $0.rawValue }, selectedTeams: selectedTeams.map { $0.id })
        let result = await scannerService.addPlayer(with: qrPlayerData)
        switch result {
        case .success:
            viewState = .addSuccess
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayName = ""
                self.playerPositions.removeAll()
                self.selectedTeams.removeAll()
                self.isUploading = false
                self.uploaded = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.uploaded = false
                }
            }
        case .failure(let failure):
            print(String(describing: failure))
            viewState = .addSuccess
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
        displayName.isEmpty || playerPositions.isEmpty
    }
}
