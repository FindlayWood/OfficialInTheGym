//
//  File.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import Foundation

class ClubHomeViewModel: ObservableObject {
    
    @Published var isShowingScanner: Bool = false
    
    var goToTeams: (() -> Void)?
    var goToPlayers: (() -> Void)?
    var goToGroups: (() -> Void)?
    var goToStaff: (() -> Void)?
    var goToQRScanner: (() -> Void)?
    
    var clubModel: RemoteClubModel
    
    init(clubModel: RemoteClubModel) {
        self.clubModel = clubModel
    }
    
    func teamsAction() {
        goToTeams?()
    }
    func playersAction() {
        goToPlayers?()
    }
    func groupsAction() {
        goToGroups?()
    }
    func staffAction() {
        goToStaff?()
    }
    func qrScannerAction() {
        goToQRScanner?()
    }
}
