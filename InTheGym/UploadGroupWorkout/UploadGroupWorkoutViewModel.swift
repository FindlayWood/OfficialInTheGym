////
////  UploadGroupWorkoutViewModel.swift
////  InTheGym
////
////  Created by Findlay Wood on 19/08/2021.
////  Copyright © 2021 FindlayWood. All rights reserved.
////
//
//import Foundation
//
//class UploadGroupWorkoutViewModel {
//    
//    var uploadableWorkout: UploadableWorkout!
//    
//    var apiService: FirebaseDatabaseWorkoutManagerService
//    
//    init(apiService: FirebaseDatabaseWorkoutManagerService) {
//        self.apiService = apiService
//    }
//    
//    func uploadWorkout() {
//        WorkoutEndpoints.postGroupWorkout(id: uploadableWorkout.assignee.uid,
//                                          workout: uploadableWorkout.workout,
//                                          service: apiService).post { result in
//                                            switch result {
//                                            case .success(_):
//                                                print("workout has been uploaded")
//                                            case .failure(let error):
//                                                print(error.localizedDescription)
//                                            }
//                                          }
//    }
//}
