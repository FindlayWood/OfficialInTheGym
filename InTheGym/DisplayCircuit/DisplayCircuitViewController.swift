//
//  DisplayCircuitViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class DisplayCircuitViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var tableview:UITableView!

    
    var exercises : [CircuitTableModel]!
    var circuit : circuit!
    var workout : WorkoutDelegate!
    var exercisePosition : Int!
    
    var adapter : DisplayCircuitAdapter!
    
    lazy var viewModel: DisplayCircuitViewModel = {
        return DisplayCircuitViewModel(workout: self.workout, position: exercisePosition)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = DisplayCircuitAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.tableFooterView = UIView()
        tableview.register(UINib(nibName: "DisplayCircuitExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "DisplayCircuitExerciseTableViewCell")
        tableview.backgroundColor = Constants.lightColour
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initUI()
    }
    
    func initUI(){
        self.navigationItem.title = circuit.exercise
        if !isButtonInteractionEnabled() {
            displayShadowView()
        } else if !circuit.completed.value! {
            let rightBarButton = UIBarButtonItem(title: "Completed", style: .done, target: self, action: #selector(completePressed(_:)))
            self.navigationItem.rightBarButtonItem = rightBarButton
        } 

    }
    
    func displayShadowView(){
        let flashView = UIView()
        flashView.frame = self.view.frame
        flashView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.view.insertSubview(flashView, at: 2)
        flashView.isUserInteractionEnabled = false
    }
    
    @IBAction func completePressed(_ sender:UIButton){
        if self.isButtonInteractionEnabled() {
            let alert = SCLAlertView()
            let rpe = alert.addTextField()
            rpe.placeholder = "enter rpe 1-10..."
            rpe.keyboardType = .numberPad
            rpe.becomeFirstResponder()
            alert.addButton("SAVE") {
                if rpe.text == "" {
                    self.showError()
                }else if Int((rpe.text)!)! < 1 || Int((rpe.text)!)! > 10{
                    self.showError()
                }else{
                    // haptic feedback : complete exercise
                    let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                    notificationFeedbackGenerator.prepare()
                    notificationFeedbackGenerator.notificationOccurred(.success)
                    self.circuit.newRPE.value = Int(rpe.text!)
                    self.circuit.completed.value = true
                    rpe.resignFirstResponder()
                    self.viewModel.completeCircuit(with: Int(rpe.text!)!)
                    self.uploadedView()
                }
                
                
            }
            alert.showSuccess("RPE", subTitle: "Enter rpe for exercise title!!!",closeButtonTitle: "cancel")
        }
    }
    
    func uploadedView(){
        let showView = UIView()
        showView.backgroundColor = .white
        self.view.addSubview(showView)
        showView.frame = view.frame
        let label = UILabel()
        label.text = "Circuit Complete!"
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .black
        showView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: showView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: showView.centerYAnchor).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showView.removeFromSuperview()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showError(){
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Enter a score between 1 and 10", closeButtonTitle: "ok", animationStyle: .noAnimation)
    }
}


extension DisplayCircuitViewController: DisplayCircuitProtocol {
    
    func getData(at indexPath: IndexPath) -> CircuitTableModel {
        return exercises[indexPath.section]
    }
    
    func retreiveNumberOfExercises() -> Int {
        return exercises.count
    }
    
    func exerciseCompleted(at indexPath: IndexPath) {
        viewModel.completedExercise(at: indexPath)
    }
    
    func completedExercise(on cell: UITableViewCell) {
        let index = tableview.indexPath(for: cell)!
        let exerciseIndex = exercises[index.section].exerciseOrder
        let exerciseSetIndex = exercises[index.section].set - 1
        let completedIndexPath = IndexPath(item: exerciseSetIndex, section: exerciseIndex)
        viewModel.completedExercise(at: completedIndexPath)
        self.exercises[index.section].completed = true
        self.circuit.exercises![exerciseIndex].completedSets![exerciseSetIndex] = true
        UIView.animate(withDuration: 0.5) {
            cell.backgroundColor = .green
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                cell.backgroundColor = Constants.offWhiteColour
            } completion: { (_) in
                let lastIndexToScroll = self.tableview.numberOfSections - 1
                if index.section < lastIndexToScroll{
                    let indexToScroll = IndexPath.init(row: 0, section: index.section + 1)
                    self.tableview.scrollToRow(at: indexToScroll, at: .top, animated: true)
                }
            }
        }
    }
    
    func isButtonInteractionEnabled() -> Bool {
        if let workout = workout as? workout{
            if workout.startTime != nil && workout.completed == false{
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
