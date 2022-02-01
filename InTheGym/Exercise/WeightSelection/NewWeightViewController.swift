//
//  NewWeightViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

// this page is used instead of weightviewcontroller

import UIKit
import SCLAlertView
import Firebase

class NewWeightViewController: UIViewController, Storyboarded {
    
    weak var newCoordinator: WeightSelectionFlow?
    weak var exerciseViewModel: ExerciseCreationViewModel?
    
    weak var coordinator: CreationFlow?
    var newExercise: exercise?
    var selectedIndexInt: Int? = nil
    var selectedState: setSelected = .allSelected
    
    var display = WeightView()
    var adapter: WeightAdapter!
    
    lazy var WeightArray: [String] = {
        //guard let exercise = newExercise else {return []}
        guard let exerciseViewModel = exerciseViewModel else {return []}
        if exerciseViewModel.exercise.weight.isEmpty {
            let array = Array(repeating: "", count: exerciseViewModel.exercise.sets)
            return array
        } else {
            return exerciseViewModel.exercise.weight
        }
    }()
    
    
    func setUp() {
        display.kgButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.lbsButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.percentageButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.bodyweightButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.bodyWeightPercentButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.maxButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.updateButton.addTarget(self, action: #selector(updatePressed(_:)), for: .touchUpInside)
        
        display.nextButton.addTarget(self, action: #selector(nextPressed(_:)), for: .touchUpInside)
        display.skipButton.addTarget(self, action: #selector(skipPressed(_:)), for: .touchUpInside)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        
        if exerciseViewModel?.exercisekind == .live || coordinator is AMRAPCoordinator {
            navigationItem.rightBarButtonItem?.isEnabled = true
            //display.nextButton.isHidden = false
            display.weightMeasurementField.text = sender.titleLabel?.text
            if sender == display.maxButton || sender == display.bodyweightButton {
                display.numberTextfield.text = ""
                display.numberTextfield.isUserInteractionEnabled = false
                //display.maxButton.isSelected = true
            } else {
                display.numberTextfield.isUserInteractionEnabled = true
                //display.maxButton.isSelected = false
                display.numberTextfield.becomeFirstResponder()
            }
            
        } else {
            display.updateButton.isHidden = false
            display.weightMeasurementField.text = sender.titleLabel?.text
            if sender == display.maxButton || sender == display.bodyweightButton {
                display.numberTextfield.text = ""
                display.numberTextfield.isUserInteractionEnabled = false
                //display.maxButton.isSelected = true
            } else {
                display.numberTextfield.isUserInteractionEnabled = true
                //display.maxButton.isSelected = false
                display.numberTextfield.becomeFirstResponder()
            }
            
        }
        
        

    }
    @objc func updatePressed(_ sender: UIButton) {
        guard let number = display.numberTextfield.text,
              let measurement = display.weightMeasurementField.text
        else {
            showEmptyAlert()
            return
        }
        if (number.isEmpty || measurement.isEmpty) && !(measurement == "max" || measurement == "bw") {
            showEmptyAlert()
        } else {
            switch selectedState {
            case .allSelected:
                if exerciseViewModel?.exercisekind == .amrap || exerciseViewModel?.exercisekind == .emom {
                    WeightArray = [number + measurement]
                } else {
                    WeightArray = WeightArray.map { _ in number + measurement}
                }
            case .singleSelected(let index):
                WeightArray[index] = number + measurement
            }
            display.topCollection.reloadData()
            sender.isHidden = true
            display.weightMeasurementField.text = ""
            display.numberTextfield.text = ""
            //display.nextButton.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true
        }

    }
    
    @IBAction func nextPressed(_ sender:UIButton){
//        guard let newExercise = newExercise else {return}
        guard let measurement = display.weightMeasurementField.text,
              let number = display.numberTextfield.text
        else {return}
//        
//        if coordinator is LiveWorkoutCoordinator {
//            if measurement == "max" || measurement == "bw" {
//                if newExercise.weightArray == nil {
//                    newExercise.weightArray = [measurement]
//                } else {
//                    newExercise.weightArray?.append(measurement)
//                }
//            } else {
//                if number.isEmpty {
//                    showEmptyAlert()
//                } else {
//                    let newWeight = number + measurement
//                    if newExercise.weightArray == nil {
//                        newExercise.weightArray = [newWeight]
//                    } else {
//                        newExercise.weightArray?.append(newWeight)
//                    }
//                }
//            }
//        }
//            
//            
////            if display.maxButton.isSelected {
////                if newExercise.weightArray == nil {
////                    newExercise.weightArray = ["MAX"]
////                } else {
////                    newExercise.weightArray?.append("MAX")
////                }
////            } else {
////                guard let number = display.numberTextfield.text,
////                      let measurement = display.weightMeasurementField.text
////                else {
////                    return
////                }
////                if number.isEmpty || measurement.isEmpty {
////                    showEmptyAlert()
////                } else {
////                    let newWeight = number + measurement
////                    if newExercise.weightArray == nil {
////                        newExercise.weightArray = [newWeight]
////                    } else {
////                        newExercise.weightArray?.append(newWeight)
////                    }
////                }
////            }
////        }
//        else if coordinator is AMRAPCoordinator || coordinator is EMOMCoordinator {
//            if measurement == "max" || measurement == "bw" {
//                newExercise.weight = measurement
//            } else {
//                if number.isEmpty || measurement.isEmpty {
//                    showEmptyAlert()
//                } else {
//                    let newWeight = number + measurement
//                    newExercise.weight = newWeight
//                }
//            }
//        } else {
//            newExercise.weightArray = WeightArray
//        }
//        coordinator?.weightSelected(newExercise)
        
        switch exerciseViewModel?.exercisekind {
        case .regular, .emom, .amrap, .circuit:
            exerciseViewModel?.addWeight(WeightArray)
        case .live:
            if measurement == "max" || measurement == "bw" {
                exerciseViewModel?.appendToWeight(measurement)
            } else if number.isEmpty {
                showEmptyAlert()
            } else {
                let newWeight = number + measurement
                exerciseViewModel?.appendToWeight(newWeight)
            }
        case .none:
            break
        }
        
        //exerciseViewModel?.addWeight(WeightArray)
        newCoordinator?.next()
    }
    
    @objc func skipPressed(_ sender: UIButton) {
        
        guard let newExercise = newExercise else {return}
        if coordinator is LiveWorkoutCoordinator {
            newExercise.weightArray?.append("")
        } else {
            WeightArray = WeightArray.map { _ in "" }
            newExercise.weightArray = WeightArray
        }
        coordinator?.weightSelected(newExercise)
        
        exerciseViewModel?.addWeight(WeightArray)
        newCoordinator?.next()
    }
    
    
    

    fileprivate func initAdapter() {
        adapter = WeightAdapter(delegate: self)
        display.topCollection.delegate = adapter
        display.topCollection.dataSource = adapter
        display.topCollection.register(WeightCollectionCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        hideKeyboardWhenTappedAround()
        
        initAdapter()
        setUp()
        
        switch coordinator{
        case is RegularWorkoutCoordinator:
            display.pageNumberLabel.text = "5 of 6"
        case is LiveWorkoutCoordinator:
            display.pageNumberLabel.text = "2 of 2"
        case is AMRAPCoordinator:
            display.pageNumberLabel.text = "4 of 4"
        case is CircuitCoordinator:
            display.pageNumberLabel.text = "5 of 5"
        case is EMOMCoordinator:
            display.pageNumberLabel.text = "5 of 5"
        default:
            break
        }
        
        if exerciseViewModel?.exercisekind == .live {
            display.topCollection.isHidden = true
        }
        
        initNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getViewableFrameWithBottomSafeArea()
//        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Weight"
        editNavBarColour(to: .darkColour)
    }
    
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed(_:)))
        navigationItem.rightBarButtonItem = nextButton
        nextButton.isEnabled = false
    }
    
    func showEmptyAlert(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("Enter a Weight!", subTitle: "You have not entered a number for the weight. To enter a number tap on the left side of the big dark blue box. You can continue without entering a weight by pressing the SKIP button near the bottom of the screen.", closeButtonTitle: "OK")
    }
    
 
}

extension NewWeightViewController: WeightAdapterProtocol {
    func getData(at indexPath: Int) -> WeightModel {
        let rep = exerciseViewModel?.exercise.reps[indexPath] ?? 0
        let weight = WeightArray[indexPath]
        return WeightModel(rep: rep, weight: weight, index: indexPath + 1)
    }
    
    func numberOfItems() -> Int {
        return WeightArray.count
    }
    
    func itemSelected(at indexPath: Int) {
        if !(exerciseViewModel?.exercisekind == .live) {
            switch selectedState {
            case .allSelected:
                selectedState = .singleSelected(indexPath)
                selectedIndexInt = indexPath
                display.updateButton.setTitle("UPDATE SET \(indexPath + 1)", for: .normal)
                display.topCollection.scrollToItem(at: IndexPath(item: indexPath, section: 0), at: .centeredHorizontally, animated: true)
            case .singleSelected(let index):
                if index == indexPath {
                    selectedState = .allSelected
                    selectedIndexInt = nil
                    display.updateButton.setTitle("UPDATE ALL SETS", for: .normal)
                } else {
                    selectedState = .singleSelected(indexPath)
                    selectedIndexInt = indexPath
                    display.updateButton.setTitle("UPDATE SET \(indexPath + 1)", for: .normal)
                    display.topCollection.scrollToItem(at: IndexPath(item: indexPath, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
            display.topCollection.reloadData()
        }
    }
    
    func selectedIndex() -> Int? {
        return selectedIndexInt
    }
}
