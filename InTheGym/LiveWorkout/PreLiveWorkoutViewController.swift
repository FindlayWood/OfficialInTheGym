//
//  PreLiveWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 20/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import SCLAlertView

class PreLiveWorkoutViewController: UIViewController, Storyboarded {
    
    weak var coordinator: WorkoutsCoordinator?
    
    var apiService = FirebaseAPIWorkoutManager.shared
    
    var display = PreLiveWorkoutView()
    
    var adapter: PreLiveWorkoutAdapter!
    
    lazy var viewModel: PreLiveWorkoutViewModel = {
        return PreLiveWorkoutViewModel(apiService: apiService)
    }()
    
    @IBOutlet weak var titlefield:UITextField!
    
    let userID = Auth.auth().currentUser!.uid

    override func viewDidLoad() {
        super.viewDidLoad()

        titlefield.delegate = self
        titlefield.tintColor = Constants.darkColour
        titlefield.returnKeyType = .done
        navigationItem.title = "Live Workout Title"
        hideKeyboardWhenTappedAround()
        loadDisplay()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top)
        view.addSubview(display)
    }
    
    func loadDisplay() {
        adapter = PreLiveWorkoutAdapter(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = .white
        display.continueButton.addTarget(self, action: #selector(continuePressed(_:)), for: .touchUpInside)
    }
    
    @IBAction func continuePressed(_ sender:UIButton) {
        if titlefield.text?.trimmingCharacters(in: .whitespaces) == "" {
            let alert = SCLAlertView()
            alert.showError("Enter a title!", subTitle: "You must enter a title to begin the workout. The title can be anything you want.")
        } else {
            guard let title = titlefield.text else {return}
            viewModel.startLiveWorkout(with: title) { [weak self] liveWorkoutModel in
                if let liveWorkout = liveWorkoutModel {
                    self?.coordinator?.startLiveWorkout(liveWorkout)
                }
            }
            
//            let workoutRef = Database.database().reference().child("Workouts").child(self.userID).childByAutoId()
//            let workoutID = workoutRef.key!
//            let workoutTitle = titlefield.text!
//            let workoutData = ["completed":false,
//                               "createdBy":ViewController.username!,
//                               "title":workoutTitle,
//                               "startTime":Date.timeIntervalSinceReferenceDate,
//                               "liveWorkout": true,
//                               "creatorID":self.userID,
//                               "workoutID":workoutID,
//                               "fromDiscover":false,
//                               "assigned":false] as [String : AnyObject]
//            workoutRef.setValue(workoutData)
//            guard let workoutModel = liveWorkout(data: workoutData) else {return}
//            coordinator?.startLiveWorkout(workoutModel)
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.trimmingCharacters(in: .whitespaces) != ""{
            print("move to next with title = \(textField.text!)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }

}

extension PreLiveWorkoutViewController: PreLiveWorkoutProtocol {
    func getData(at indexPath: IndexPath) -> String {
        return viewModel.getData(at: indexPath)
    }
    
    func numberOfRows() -> Int {
        return viewModel.numberOfItems
    }
    
    func itemSelected(at indexPath: IndexPath) {
        let newTitle = viewModel.getData(at: indexPath)
        display.titleField.text = newTitle
    } 
}
