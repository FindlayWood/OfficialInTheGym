//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/09/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// this page is not for saved workouts
// it is for the new implementation of sets page
// it asks the user for how many sets on an exercise
// and then passes onto the new implementation of reps page

import UIKit
import SCLAlertView

class ExerciseSetsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: RegularAndCircuitFlow?
    
    weak var newCoordinator: SetsSelectionCoordinator?
    
    weak var exerciseViewModel: ExerciseCreationViewModel?
    
    var newExercise: exercise?
    
    var display = SetsView()
  
    private var setNumber: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sets"
        
        view.backgroundColor = .white
        
        display.collection.delegate = self
        display.collection.dataSource = self
        
//        switch coordinator{
//        case is RegularWorkoutCoordinator:
//            pageNumberLabel.text = "3 of 6"
//        case is CircuitCoordinator:
//            pageNumberLabel.text = "3 of 5"
//        default:
//             break
//        }
        initNavBar()
        initActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    func initActions() {
        display.plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        display.minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
    }

}

extension ExerciseSetsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetsCell.cellID, for: indexPath) as! SetsCell
        cell.numberLabel.text = (indexPath.item + 1).description
        if (indexPath.item + 1) == setNumber {
            cell.backgroundColor = Constants.darkColour
        } 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setNumber = indexPath.item + 1
        display.setLabel.text = setNumber.description
        display.collection.reloadData()
        display.collection.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func plus() {
        if setNumber < 20 {
            setNumber += 1
            display.setLabel.text = setNumber.description
            display.collection.reloadData()
            display.collection.scrollToItem(at: IndexPath(item: setNumber - 1, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    @objc func minus() {
        if setNumber > 1 {
            setNumber -= 1
            display.setLabel.text = setNumber.description
            display.collection.reloadData()
            display.collection.scrollToItem(at: IndexPath(item: setNumber - 1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func nextPressed() {
//        guard let newExercise = newExercise else {return}
//        newExercise.sets = setNumber
//        let completedArray = Array(repeating: false, count: setNumber)
//        newExercise.completedSets = completedArray
//        coordinator?.setsSelected(newExercise)
        
        exerciseViewModel?.addSets(setNumber)
        newCoordinator?.next(viewModel: exerciseViewModel!)
    }
}
