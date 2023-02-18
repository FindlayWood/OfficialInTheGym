//
//  ExerciseRatingViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class ExerciseRatingViewModel: ObservableObject {
    // MARK: - Publishers
    @Published var isLoading: Bool = false
    @Published var ratingSelected: Bool = false
    @Published var selectedRating: Int?
    @Published var error: Error?
    
    @Published var currentRating: Double?
    
    @Published var showAddRating: Bool = false
    @Published var submittedRating: Int?
    
    @Published var ratingDict: [Int: Int] = [0:0, 1:0, 2:0, 3:0, 4: 0, 5:0, 6:0, 7:0, 8:0, 9:0, 10:0]
    @Published var heights: [Int: CGFloat] = [:]
    
    var addedRatingPublisher: PassthroughSubject<Int,Never>?
    var addedStampPublisher: PassthroughSubject<[Stamps],Never>?
    var uploadSuccessful = PassthroughSubject<Void,Never>()
    
    // MARK: - Properties
    var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
    var navigationTitle: String = "Exercise Rating"
    var ratings: [Int] = []
    var exerciseModel: DiscoverExerciseModel!
    var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
        self.apiService = apiService
    }
    // MARK: - Actions
    func initSubscribers() {
        
    }
    func loadRatings() {
        ratings.forEach { ratingDict[$0, default: 0] += 1 }
        for (key, value) in ratingDict {
            if ratings.count > 0 {
                heights[key] = CGFloat((Double(value) / Double(ratings.count)) * 50)
            } else {
                heights[key] = 0
            }
        }
    }
    func submitRating() {
        guard let rating = submittedRating else {return}
        ratings.append(rating)
        ratingDict[rating]? += 1
        
        let total = ratings.reduce(0, +)
        currentRating = Double(total) / Double(ratings.count)
        
        for (key, value) in ratingDict {
            if ratings.count > 0 {
                heights[key] = CGFloat((Double(value) / Double(ratings.count)) * 50)
            } else {
                heights[key] = 0
            }
        }
        selectedRating = rating
        addedRatingPublisher?.send(rating)
    }
    func submitStamp() {
        var stamps = [Stamps]()
        if UserDefaults.currentUser.verifiedAccount ?? false {
            stamps.append(.verified)
        }
        if UserDefaults.currentUser.eliteAccount ?? false {
            stamps.append(.elite)
        }
        addedStampPublisher?.send(stamps)
    }
    // MARK: - Functions
}
