//
//  AddMoreToExerciseViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Combine

class AddMoreToExerciseViewModel {
    
    // MARK: - Publishers
    var timeUpdatedPublisher = PassthroughSubject<[Int]?,Never>()
    var distanceUpdatedPublisher = PassthroughSubject<[String]?,Never>()
    var restTimeUpdatedPublisher = PassthroughSubject<[Int]?,Never>()
    var noteUpdatedPublisher = PassthroughSubject<String,Never>()
    
    
    // MARK: - Properties
    var exercise: ExerciseModel!
    
    var exerciseCreationViewModel: ExerciseCreationViewModel!
    
    let data: [AddMoreCellModel] = [.init(title: "Time", imageName: "clock_icon", value: Observable<String>()),
                                    .init(title: "Distance", imageName: "distance_icon", value: Observable<String>()),
                                    .init(title: "Rest Time", imageName: "restTime_icon", value: Observable<String>()),
                                    .init(title: "Note", imageName: "note_icon", value: Observable<String>())]
    
    var numberOfItems: Int {
        return data.count
    }
    
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: - Actions
    
    // MARK: - Functions
    func observePublishers() {
        timeUpdatedPublisher
            .sink { [weak self] in self?.exercise.time = $0}
            .store(in: &subscriptions)
        distanceUpdatedPublisher
            .sink { [weak self] in self?.exercise.distance = $0}
            .store(in: &subscriptions)
        restTimeUpdatedPublisher
            .sink { [weak self] in self?.exercise.restTime = $0}
            .store(in: &subscriptions)
        noteUpdatedPublisher
            .sink { [weak self] in self?.exercise.note = $0}
            .store(in: &subscriptions)
    }
    
    func getData(at indexPath: IndexPath) -> AddMoreCellModel {
        return data[indexPath.row]
    }
}
