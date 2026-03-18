//
//  RequestsTableViewCellViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine


class RequestTableViewCellViewModel: NSObject {
    
    // MARK: - Publishers
    
    var successfullyAccepted = PassthroughSubject<RequestCellModel,Never>()
    
    var successfullyDeclined = PassthroughSubject<RequestCellModel,Never>()
    
    var errorPublisher = PassthroughSubject<Error,Never>()
    
    @Published var isLoading: Bool = false
    
    // MARK: - Properties
    
    var cellModel: RequestCellModel!
    
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    func acceptRequest() {
        cellModel.isLoading = true
        let playerRequestModel = PlayerRequestUploadModel(playerID: UserDefaults.currentUser.uid, coachID: cellModel.user.uid)
        let coachRequestModel = CoachRequestUploadModel(playerID: UserDefaults.currentUser.uid, coachID: cellModel.user.uid)
        let playerCoachModel = PlayerCoachModel(playerID: UserDefaults.currentUser.uid, coachID: cellModel.user.uid)
        let coachPlayerModel = CoachPlayersModel(coachID: cellModel.user.uid, playerID: UserDefaults.currentUser.uid)
        let uploadPoints: [FirebaseMultiUploadDataPoint] = [
            FirebaseMultiUploadDataPoint(value: nil, path: playerRequestModel.internalPath),
            FirebaseMultiUploadDataPoint(value: nil, path: coachRequestModel.internalPath),
            playerCoachModel.getUploadPoint(),
            coachPlayerModel.getUploadPoint()
        ]
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.successfullyAccepted.send(self.cellModel)
                self.isLoading = false
            case .failure(let error):
                self.errorPublisher.send(error)
                self.isLoading = false
            }
        }
    }
    func declineRequest() {
        cellModel.isLoading = true
        let playerRequestModel = PlayerRequestUploadModel(playerID: UserDefaults.currentUser.uid, coachID: cellModel.user.uid)
        let coachRequestModel = CoachRequestUploadModel(playerID: UserDefaults.currentUser.uid, coachID: cellModel.user.uid)
        let uploadPoints: [FirebaseMultiUploadDataPoint] = [
            FirebaseMultiUploadDataPoint(value: nil, path: playerRequestModel.internalPath),
            FirebaseMultiUploadDataPoint(value: nil, path: coachRequestModel.internalPath)
        ]
        apiService.multiLocationUpload(data: uploadPoints) { [weak self] result in
            guard let self = self else {return}
            switch result {
            case .success(_):
                self.successfullyDeclined.send(self.cellModel)
                self.isLoading = false
            case .failure(let error):
                self.errorPublisher.send(error)
                self.isLoading = false
            }
        }
    }
}
