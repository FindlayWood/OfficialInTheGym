//
//  MoreGroupInfoViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class MoreGroupInfoViewModel {
    
    // MARK: - Callbacks
    var leaderLoadedCallBack: (() -> ())?
    var membersLoadedCallBack: (() -> ())?
    var newInfoSavedCallBack: (() -> ())?
    
    // MARK: - Properties

    var apiService: FirebaseAPIGroupServiceProtocol!

    var members: [Users] = [] {
        didSet {
            membersLoadedSuccessfully = true
            membersLoadedCallBack?()
        }
    }
    var membersCount: Int {
        return members.count
    }
    
    var leader: Users! {
        didSet {
            leaderLoadedCallBack?()
        }
    }
    
    var membersLoadedSuccessfully: Bool = false
    var leaderLoadedSuccessfully: Bool = false
    
    init(apiService: FirebaseAPIGroupServiceProtocol) {
        self.apiService = apiService
    }
    
    
    func loadLeader(from group: MoreGroupInfoModel) {
        apiService.loadLeader(from: group) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let leader):
                self.leader = leader
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func loadMembers(from group: MoreGroupInfoModel) {
        apiService.loadMembers(from: group) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(let returnedMembers):
                self.members = returnedMembers
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func saveNewGroupInfo(from group: MoreGroupInfoModel) {
        apiService.saveNewGroupInfo(from: group) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.newInfoSavedCallBack?()
            }
        }
    }
    
    func getMember(at indexPath: IndexPath) -> Users {
        return members[indexPath.row]
    }
    
    func getData(at indexPath: IndexPath, from info: MoreGroupInfoModel) -> String {
        switch indexPath.section {
        case 0:
            return info.groupName
        case 1:
            return info.description ?? "description..."
        case 2:
            return "Edit Members"
        default:
            return "error"
        }
    }
    
    func isEditingEnabled(for leaderID: String) -> Bool {
        guard let userID = Auth.auth().currentUser?.uid else {
            return false
        }
        return userID == leaderID 
    }
}
