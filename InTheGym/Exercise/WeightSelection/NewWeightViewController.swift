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
    
    weak var coordinator: RegularAndLiveFlow?
    var newExercise: exercise?
    var selectedIndexInt: Int? = nil
    var selectedState: setSelected = .allSelected
    
    var display = WeightView()
    var adapter: WeightAdapter!
    
    lazy var WeightArray: [String] = {
        guard let exercise = newExercise else {return []}
        let array = Array(repeating: "", count: exercise.sets ?? 0)
        return array
    }()
    
    
    func setUp() {
        display.kgButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.lbsButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.percentageButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.maxButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.kmButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.milesButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.minsButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.secondsButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        display.updateButton.addTarget(self, action: #selector(updatePressed(_:)), for: .touchUpInside)
        
        display.nextButton.addTarget(self, action: #selector(nextPressed(_:)), for: .touchUpInside)
        display.skipButton.addTarget(self, action: #selector(skipPressed(_:)), for: .touchUpInside)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        display.updateButton.isHidden = false
        display.weightMeasurementField.text = sender.titleLabel?.text
        if sender == display.maxButton {
            display.numberTextfield.text = ""
            display.numberTextfield.isUserInteractionEnabled = false
            display.maxButton.isSelected = true
        } else {
            display.numberTextfield.isUserInteractionEnabled = true
            display.maxButton.isSelected = false
            display.numberTextfield.becomeFirstResponder()
        }
    }
    @objc func updatePressed(_ sender: UIButton) {
        guard let number = display.numberTextfield.text,
              let measurement = display.weightMeasurementField.text
        else {
            showEmptyAlert()
            return
        }
        if (number.isEmpty || measurement.isEmpty) && !display.maxButton.isSelected {
            showEmptyAlert()
        } else {
            switch selectedState {
            case .allSelected:
                WeightArray = WeightArray.map { _ in number + measurement}
            case .singleSelected(let index):
                WeightArray[index] = number + measurement
            }
            display.topCollection.reloadData()
            sender.isHidden = true
            display.weightMeasurementField.text = ""
            display.numberTextfield.text = ""
            display.nextButton.isHidden = false
        }

    }
    
    @IBAction func nextPressed(_ sender:UIButton){
        guard let newExercise = newExercise else {return}
        
        if coordinator is LiveWorkoutCoordinator {
            if display.maxButton.isSelected {
                newExercise.weightArray?.append("MAX")
            } else {
                guard let number = display.numberTextfield.text,
                      let measurement = display.weightMeasurementField.text
                else {
                    return
                }
                if number.isEmpty || measurement.isEmpty {
                    showEmptyAlert()
                } else {
                    let newWeight = number + measurement
                    newExercise.weightArray?.append(newWeight)
                }
            }
        } else {
            newExercise.weightArray = WeightArray
        }
        coordinator?.weightSelected(newExercise)
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
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        adapter = WeightAdapter(delegate: self)
        display.topCollection.delegate = adapter
        display.topCollection.dataSource = adapter
        display.topCollection.register(WeightCollectionCell.self, forCellWithReuseIdentifier: "cell")
        setUp()
        
        switch coordinator{
        case is RegularWorkoutCoordinator:
            display.pageNumberLabel.text = "5 of 6"
        case is LiveWorkoutCoordinator:
            display.pageNumberLabel.text = "2 of 2"
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = "Weight"
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.darkColour
    }
    
    func showEmptyAlert(){
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, showCircularIcon: true
        )
        let alert = SCLAlertView(appearance: appearance)
//        alert.addButton("Continue Anyway") {
//            print("continuing to next page with no weight...")
//            self.skipPressed(UIButton())
//        }
        alert.showError("Enter a Weight!", subTitle: "You have not entered a number for the weight for this exercise. To enter a weight tap on the left side of the big dark blue box. You can continue without entering a weight if you would like. Continue with no weight?", closeButtonTitle: "OK")
    }
    
 
}

extension NewWeightViewController: WeightAdapterProtocol {
    func getData(at indexPath: Int) -> WeightModel {
        guard let exercise = newExercise else {return WeightModel(rep: 0, weight: "", index: 0)}
        let rep = exercise.repArray?[indexPath] ?? 0
        let weight = WeightArray[indexPath]
        return WeightModel(rep: rep, weight: weight, index: indexPath + 1)
    }
    
    func numberOfItems() -> Int {
        return WeightArray.count
    }
    
    func itemSelected(at indexPath: Int) {
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
    
    func selectedIndex() -> Int? {
        return selectedIndexInt
    }
}
