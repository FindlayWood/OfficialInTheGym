//
//  NewRepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

//this is the new reps page. it is used instead of repviewcontroller

import UIKit
import SCLAlertView

enum setSelected {
    case allSelected
    case singleSelected(Int)
}

class NewRepsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CreationFlow?
    
    weak var newCoordinator: RepsSelectionCoordinator?
    
    weak var exerciseViewModel: ExerciseCreationViewModel?
    
    var newExercise: exercise?
    
    var display = RepsView()
    
    lazy var repIntArray: [Int] = {
        var array = [Int]()
        //guard let newExercise = newExercise else {return []}
        array = Array(repeating: 1, count: exerciseViewModel?.exercise.sets ?? 0)
        return array
    }()
    
    private var repCounter: Int = 1
    
    private var selectedState: setSelected = .allSelected
    private var topSelectedIndex: Int? = nil
    
    private var topAdapter: RepsTopCollectionAdapter!
    private var bottomAdapter: RepsBottomCollectionAdapter!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    
    var fromLiveWorkout:Bool!
    var whichExercise:Int!
    var workoutID:String!
    

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        self.navigationItem.title = "Reps"
  
        switch coordinator{
        case is CircuitCoordinator:
            display.pageNumberLabel.text = "4 of 4"
        case is RegularWorkoutCoordinator:
            display.pageNumberLabel.text = "4 of 6"
        case is LiveWorkoutCoordinator:
            display.topCollection.isHidden = true
            display.pageNumberLabel.text = "1 of 2"
        case is AMRAPCoordinator:
            display.topCollection.isHidden = true
            display.pageNumberLabel.text = "3 of 4"
        default:
            break
        }
        
        initAdapter()
        setupActions()
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .lightColour)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
        view.addSubview(display)
    }
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed))
        navigationItem.rightBarButtonItem = nextButton
    }
    
    fileprivate func setupActions() {
        display.minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        display.plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        display.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
    }
    
    fileprivate func initAdapter() {
        topAdapter = RepsTopCollectionAdapter(delegate: self)
        bottomAdapter = RepsBottomCollectionAdapter(delegate: self)
        display.topCollection.delegate = topAdapter
        display.topCollection.dataSource = topAdapter
        display.bottomCollection.delegate = bottomAdapter
        display.bottomCollection.dataSource = bottomAdapter
    }

}

extension NewRepsViewController: repsTopCollectionProtocol {
    func getData(at index: IndexPath) -> Int {
        return repIntArray[index.item]
    }
    func retreiveNumberOfItems() -> Int {
        return repIntArray.count
    }
    func itemSelected(at indec: IndexPath) {
        switch selectedState{
        case .allSelected:
            selectedState = .singleSelected(indec.item)
            topSelectedIndex = indec.item
            repCounter = repIntArray[indec.item]
            if repCounter == 0 {
                display.repLabel.text = "M"
            } else {
                display.repLabel.text = repCounter.description
            }
            display.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
            display.bottomCollection.reloadData()
        case .singleSelected(let selectedIndex):
            if selectedIndex == indec.item {
                selectedState = .allSelected
                topSelectedIndex = nil
            } else {
                repCounter = repIntArray[indec.item]
                if repCounter == 0 {
                    display.repLabel.text = "M"
                } else {
                    display.repLabel.text = repCounter.description
                }
                selectedState = .singleSelected(indec.item)
                topSelectedIndex = indec.item
                display.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
                display.bottomCollection.reloadData()
            }
        }
        display.topCollection.scrollToItem(at: IndexPath(item: indec.item, section: 0), at: .centeredHorizontally, animated: true)
        display.topCollection.reloadData()
    }
    func selectedIndex() -> Int? {
        return topSelectedIndex
    }
}

extension NewRepsViewController: repsbottomCollectionProtocol {
    func selectedIndex() -> Int {
        return repCounter
    }
    func bottomItemSelected(at index: IndexPath) {
        if index.item == 0 {
            display.repLabel.text = "M"
            repCounter = index.item
        } else {
            repCounter = index.item
            display.repLabel.text = repCounter.description
        }
        
        switch selectedState {
        case .allSelected:
            repIntArray = repIntArray.map { _ in repCounter }
        case .singleSelected(let index):
            repIntArray[index] = repCounter
        }
        display.bottomCollection.scrollToItem(at: IndexPath(item: index.item, section: 0), at: .centeredHorizontally, animated: true)
        display.bottomCollection.reloadData()
        display.topCollection.reloadData()
    }
}

//MARK: - button methods
extension NewRepsViewController{
    
    @objc func plus() {
        if repCounter < 99 {
            repCounter += 1
            display.repLabel.text = repCounter.description
            switch selectedState{
            case .allSelected:
                repIntArray = repIntArray.map { _ in repCounter }
            case .singleSelected(let index):
                repIntArray[index] = repCounter
            }
            display.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
            display.bottomCollection.reloadData()
            display.topCollection.reloadData()
        }
    }
    
    @objc func minus() {
        if repCounter == 1 {
            display.repLabel.text = "M"
            repCounter -= 1
        }else if repCounter > 1 {
            repCounter -= 1
            display.repLabel.text = repCounter.description
        }
        switch selectedState {
        case .allSelected:
            repIntArray = repIntArray.map { _ in repCounter }
        case .singleSelected(let index):
            repIntArray[index] = repCounter
        }
        display.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
        display.bottomCollection.reloadData()
        display.topCollection.reloadData()
    }
    
    @objc func nextPressed() {
//        guard let newExercise = newExercise else {return}
//        if coordinator is LiveWorkoutCoordinator {
//            if newExercise.repArray == nil {
//                newExercise.repArray = [repCounter]
//            } else {
//                newExercise.repArray?.append(repCounter)
//            }
//        } else if coordinator is AMRAPCoordinator || coordinator is EMOMCoordinator {
//            newExercise.reps = repCounter
//        } else {
//            newExercise.repArray = repIntArray
//        }
//        coordinator?.repsSelected(newExercise)
        if exerciseViewModel?.exercisekind == .amrap || exerciseViewModel?.exercisekind == .emom {
            exerciseViewModel?.addReps([repCounter])
        } else {
            exerciseViewModel?.addReps(repIntArray)
        }
//        exerciseViewModel?.addReps(repIntArray)
        newCoordinator?.next(viewModel: exerciseViewModel!)
    }
}
