//
//  DisplaySavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class DisplayWorkoutViewController: UIViewController, Storyboarded {
    
    weak var coordinator: WorkoutDisplayCoordinator?
    
    var flashView: FlashView!
    var bottomView: WorkoutBottomView!
    var bottomViewFrame: CGRect!
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var completeButton:UIButton!
    @IBOutlet weak var completeButtonBottomConstraint:NSLayoutConstraint!
    
    static var selectedWorkout : WorkoutDelegate!
    
    var adapter : DisplayWorkoutAdapter!
    
    var workoutHasBegun : Bool?
    
    lazy var viewModel: DisplayWorkoutViewModel = {
        return DisplayWorkoutViewModel(workout: DisplayWorkoutViewController.selectedWorkout)
    }()
    
    // array of colours to set rpe button
    let colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = DisplayWorkoutAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.tableFooterView = UIView()
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 380
        //tableview.rowHeight = 380
        tableview.register(UINib(nibName: "DisplayWorkout", bundle: nil), forCellReuseIdentifier: "DisplayWorkoutCell")
        tableview.register(UINib(nibName: "DisplayPlusTableView", bundle: nil), forCellReuseIdentifier: "DisplayPlusTableView")
        tableview.register(UINib(nibName: "DisplayWorkoutCircuitTableViewCell", bundle: nil), forCellReuseIdentifier: "DisplayWorkoutCircuitTableViewCell")
        tableview.register(DisplayAMRAPCell.self, forCellReuseIdentifier: "DisplayAMRAPCell")
        
        flashView = FlashView(frame: view.frame)
        bottomViewFrame = CGRect(x: 0, y: Constants.screenSize.height - Constants.screenSize.height * 0.15, width: Constants.screenSize.width, height: Constants.screenSize.height * 0.15)
        bottomView = WorkoutBottomView(frame: bottomViewFrame)
        
        loadTableview()
        initViewModel()
        initUI()
        initBottomView()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        tableview.reloadData()
    }
    
    func initUI(){
        navigationItem.title = DisplayWorkoutViewController.selectedWorkout.title
    }
    
    func initBottomView(){
        switch DisplayWorkoutViewController.selectedWorkout {
        
        case is publicSavedWorkout:
            self.completeButton.isHidden = true
            self.completeButtonBottomConstraint.constant = 50
        if !ViewController.admin {
            bottomView.mainButton.setTitle("Add to Workouts", for: .normal)
            bottomView.mainButton.addTarget(self, action: #selector(addToWorkouts), for: .touchUpInside)
            bottomView.tableview.delegate = self
            bottomView.flashview = flashView
            view.addSubview(flashView)
            view.addSubview(bottomView)
        }
            
        case is privateSavedWorkout:
            self.completeButton.isHidden = true
            self.completeButtonBottomConstraint.constant = 50
            if !ViewController.admin{
//                let bv = SavedWorkoutBottomView(workout: DisplayWorkoutViewController.selectedWorkout, parent: self.view)
//                bv.bottomViewSetUpClosure = { [weak self] () in
//                    self?.viewModel.addToWorkouts()
//                    DisplayTopView.displayTopView(with: "Added To Workouts", on: self!)
//                    // fucntion to add workout on viewmodel
//                }
//                bv.viewProfileTapped = { [weak self] () in
//                    guard let self = self else {return}
//                    if DisplayWorkoutViewController.selectedWorkout.creatorID == self.viewModel.userId {
//                        DisplayTopView.displayTopView(with: "Your Workout", on: self)
//                    } else {
//                        UserIDToUser.transform(userID: (DisplayWorkoutViewController.selectedWorkout.creatorID)) { user in
//                            let coordinator = self.coordinator as! WorkoutCoordinatorFlow
//                            coordinator.showUser(with: user)
//                        }
//                    }
//                }
                bottomView.mainButton.setTitle("Add to Workouts", for: .normal)
                bottomView.mainButton.addTarget(self, action: #selector(addToWorkouts), for: .touchUpInside)
                bottomView.tableview.delegate = self
                bottomView.flashview = flashView
                view.addSubview(flashView)
                view.addSubview(bottomView)
            }
            
        case is CreatedWorkoutDelegate:
            self.completeButton.isHidden = true
            self.completeButtonBottomConstraint.constant = 50
            if !(DisplayWorkoutViewController.selectedWorkout.creatorID == viewModel.userId){
                viewModel.addAView(to: DisplayWorkoutViewController.selectedWorkout)
                self.bottomView.mainButton.setTitle("Add to Saved Workouts", for: .normal)
                self.bottomView.mainButton.addTarget(self, action: #selector(addToSavedWorkouts), for: .touchUpInside)
                self.bottomView.tableview.delegate = self
                self.bottomView.flashview = flashView
                self.view.addSubview(flashView)
                self.view.addSubview(bottomView)
//                let bv = DiscoverWorkoutBottomView(workout: DisplayWorkoutViewController.selectedWorkout, parent: self.view)
//                bv.bottomViewSetUpClosure = { [weak self] () in
//                    self?.viewModel.addToSavedWorkouts()
//                }
            }
            else if !ViewController.admin{
//                let bv = SavedWorkoutBottomView(workout: DisplayWorkoutViewController.selectedWorkout, parent: self.view)
//                bv.bottomViewSetUpClosure = { [weak self] () in
//                    guard let self = self else {return}
//                    self.viewModel.addToWorkouts()
//                    DisplayTopView.displayTopView(with: "Added To Workouts", on: self)
//                }
//                bv.viewProfileTapped = { [weak self] () in
//                    guard let self = self else {return}
//                    DisplayTopView.displayTopView(with: "Your Workout", on: self)
//                }
                bottomView.mainButton.setTitle("Add to Workouts", for: .normal)
                bottomView.mainButton.addTarget(self, action: #selector(addToWorkouts), for: .touchUpInside)
                bottomView.tableview.delegate = self
                bottomView.flashview = flashView
                view.addSubview(flashView)
                view.addSubview(bottomView)
            }
            
        
        case is discoverWorkout:
            self.completeButton.isHidden = true
            self.completeButtonBottomConstraint.constant = 50
            if !DisplayWorkoutViewController.selectedWorkout.liveWorkout {
                if !(DisplayWorkoutViewController.selectedWorkout.creatorID == viewModel.userId) && DisplayWorkoutViewController.selectedWorkout.savedID != nil{
                    viewModel.addAView(to: DisplayWorkoutViewController.selectedWorkout)
//                    let bv = DiscoverWorkoutBottomView(workout: DisplayWorkoutViewController.selectedWorkout, parent: self.view)
//                    bv.bottomViewSetUpClosure = { [weak self] () in
//                        //add to saved workouts
//                        self?.viewModel.addToSavedWorkouts()
//                    }
//                    bv.profileTappedClosure = { [weak self] () in
//                        guard let self = self else {return}
//                        UserIDToUser.transform(userID: (DisplayWorkoutViewController.selectedWorkout.creatorID)) { user in
//                            let coordinator = self.coordinator as! WorkoutCoordinatorFlow
//                            coordinator.showUser(with: user)
//                        }
//                    }
                    self.bottomView.mainButton.setTitle("Add to Saved Workouts", for: .normal)
                    self.bottomView.mainButton.addTarget(self, action: #selector(addToSavedWorkouts), for: .touchUpInside)
                    self.bottomView.tableview.delegate = self
                    self.bottomView.flashview = flashView
                    self.view.addSubview(flashView)
                    self.view.addSubview(bottomView)
                    
                } else if DisplayWorkoutViewController.selectedWorkout.creatorID == viewModel.userId {
                    bottomView.mainButton.setTitle("Add to Workouts", for: .normal)
                    bottomView.mainButton.addTarget(self, action: #selector(addToWorkouts), for: .touchUpInside)
                    bottomView.tableview.delegate = self
                    bottomView.flashview = flashView
                    view.addSubview(flashView)
                    view.addSubview(bottomView)
//                    let bv = YourWorkoutBottomView(parent: self.view)
//                    self.view.addSubview(bv)
                }
            }
            
        case is workout:
            let s = DisplayWorkoutViewController.selectedWorkout as! workout
            if s.completed || ViewController.admin {
                self.completeButton.isHidden = true
                self.completeButtonBottomConstraint.constant = 50
                // no view
            }else if s.startTime != nil {
                self.completeButton.isHidden = false
                self.completeButtonBottomConstraint.constant = 0
                // no view
            }else{
                self.completeButton.isHidden = false
                self.completeButtonBottomConstraint.constant = 0
                if !ViewController.admin{
                    let bv = MainWorkoutBottomView(workout: DisplayWorkoutViewController.selectedWorkout, parent: self.view)
                    self.view.addSubview(bv)
                    bv.bottomViewSetUpClosure = { [weak self] () in
                        self?.viewModel.startTheWorkout()
                    }
                }
            }
        case is liveWorkout:
            let workout = DisplayWorkoutViewController.selectedWorkout as! liveWorkout
            if workout.completed == true {
                self.completeButton.isHidden = true
                self.completeButtonBottomConstraint.constant = 50
            } else {
                self.completeButton.isHidden = false
                self.completeButtonBottomConstraint.constant = 0
            }
        default:
            break
        }
    }
    
    func loadTableview(){
        viewModel.selectedWorkout = DisplayWorkoutViewController.selectedWorkout
        tableview.reloadData()
    }
    
    func initViewModel() {
        
        // setup delegate to self
        viewModel.delegate = self
        
        // Setup for reloadTableViewClosure
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        // Setup for bottomview
        viewModel.bottomViewSetUpClosure = { [weak self] () in
            // display bottom view
            let bottomView = self!.viewModel.bottomView
            self?.view.addSubview(bottomView)
            
        }
        
        // called when workout started
        viewModel.workoutReadyToStartClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self?.tableview.reloadData()
            }
        }
        
        viewModel.setup()
        
    }
    
    @IBAction func completedTapped(_ sender:UIButton){
        let completedWorkout = DisplayWorkoutViewController.selectedWorkout as! Completeable
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let completedVC = storyboard.instantiateViewController(withIdentifier: "WorkoutCompletedViewController") as! WorkoutCompletedViewController
        completedVC.workout = completedWorkout
        guard let exercises = DisplayWorkoutViewController.selectedWorkout.exercises else {return}
        var scores : [Int] = []
        for exercise in exercises {
            if exercise is circuit{
                let exercise = exercise as! circuit
                if let score = exercise.newRPE.value{
                    scores.append(score)
                }
            } else if exercise is exercise {
                let exercise = exercise as! exercise
                if let RPEscore = exercise.rpe {
                    scores.append(Int(RPEscore)!)
                }
            }
           
        }
        let total = scores.reduce(0, +)
        let average = Double(total) / Double(scores.count)
        let rounded = round(average * 10)/10
        if rounded.isNaN{
            completedVC.averageRPE = 0.0
        } else {
            completedVC.averageRPE = rounded
        }
        let endTime = Date.timeIntervalSinceReferenceDate
        //let startTime = (DisplayWorkoutViewController.selectedWorkout as? workout)!.startTime
        guard let startTime = completedWorkout.startTime else {return}
        let completionTimeSeconds = Int(endTime) - Int(startTime)
        completedVC.secondsToComplete = completionTimeSeconds
        completedVC.endTime = endTime
        let formatter = DateComponentsFormatter()
        
        if completionTimeSeconds > 3600{
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .abbreviated
        }else{
            formatter.allowedUnits = [.minute, .second]
            formatter.unitsStyle = .abbreviated
        }
        
        let timeString = formatter.string(from: TimeInterval(completionTimeSeconds))
        completedVC.timeString = timeString
        self.navigationController?.pushViewController(completedVC, animated: true)
    }
    
    func showError(){
        // show alertview error
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Enter a score between 1 and 10", closeButtonTitle: "ok", animationStyle: .noAnimation)
    }
    
}
extension DisplayWorkoutViewController: DisplayWorkoutProtocol{
    
    func getData(at: IndexPath) -> WorkoutType {
        return self.viewModel.getData(at: at)
    }
    
    func isLive() -> Bool {
        return self.viewModel.isLive()
    }
    
    func itemSelected(at: IndexPath) {
        if isLive() && at.section == viewModel.numberOfItems{
            // here have viewmodel method to send to next page
            // which will be body type page
        } else if viewModel.selectedWorkout?.exercises![at.section] is circuit {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextVC = storyboard.instantiateViewController(withIdentifier: "DisplayCircuitViewController") as! DisplayCircuitViewController
            let circuit: circuit = (viewModel.getData(at: at) as? circuit)!
            nextVC.circuit = circuit
            let rowModels = circuit.integrate()
            nextVC.exercises = rowModels
            nextVC.workout = DisplayWorkoutViewController.selectedWorkout
            nextVC.exercisePosition = at.section
            self.navigationController?.pushViewController(nextVC, animated: true)
        } else if viewModel.selectedWorkout?.exercises![at.section] is AMRAP {
            guard let coordinator = coordinator as? WorkoutCoordinatorFlow,
                  let amrap = viewModel.selectedWorkout?.exercises?[at.section] as? AMRAP,
                  let workout = DisplayWorkoutViewController.selectedWorkout as? workout
            else {return}
            coordinator.showAMRAP(with: amrap, at: at.section, on: workout)
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return 1
    }
    
    func retreiveNumberOfSections() -> Int {
        
        switch isLive() {
        case true:
            return viewModel.numberOfItems + 1
        case false:
            return viewModel.numberOfItems
        }
        
    }
    
    func returnInteractionEnbabled() -> Bool {
        switch viewModel.selectedWorkout {
        case is publicSavedWorkout:
            return false
        case is privateSavedWorkout:
            return false
        case is liveWorkout:
            return true
        case is discoverWorkout:
            return false
        case is workout:
            let s = DisplayWorkoutViewController.selectedWorkout as! workout
            if s.completed {
                return false
            }else if s.startTime != nil{
                return true
            }else{
                return false
            }
        default:
            return false
        }
    }
    
    
    func returnAlreadySaved(saved: Bool) {
        switch saved {
        case true:
            DisplayTopView.displayTopView(with: "Already Saved", on: self)
        case false:
            DisplayTopView.displayTopView(with: "Added to Saved Workouts", on: self)
        }
    }
    
    
    
    func rpeButtonTappped(on tableviewcell: UITableViewCell, sender: UIButton, collection: UICollectionView) {
        let index = self.tableview.indexPath(for: tableviewcell)
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
                let colourIndex = Int(rpe.text!)!-1
                sender.setTitle("\(rpe.text!)", for: .normal)
                self.viewModel.updateRPE(at: index!, with: Int(rpe.text!)!)
                UIView.animate(withDuration: 0.5) {
                    tableviewcell.backgroundColor = self.colors[colourIndex]
                    collection.backgroundColor = self.colors[colourIndex]
                    sender.setTitleColor(self.colors[colourIndex], for: .normal)
                } completion: { (_) in
                    UIView.animate(withDuration: 0.5) {
                        tableviewcell.backgroundColor =  #colorLiteral(red: 0.9251794815, green: 0.9334231019, blue: 0.9333136678, alpha: 1)
                        collection.backgroundColor = #colorLiteral(red: 0.9251794815, green: 0.9334231019, blue: 0.9333136678, alpha: 1)
                    } completion: { (_) in
                        let lastIndexToScroll = self.tableview.numberOfSections - 1
                        if index!.section < lastIndexToScroll{
                            let indexToScroll = IndexPath.init(row: 0, section: index!.section + 1)
                            self.tableview.scrollToRow(at: indexToScroll, at: .top, animated: true)
                        }
                    }
                }

            }
            
            
        }
        alert.showSuccess("RPE", subTitle: "Enter rpe for exercise title!!!",closeButtonTitle: "cancel")
    }
    
    
    func noteButtonTapped(on tableviewcell: UITableViewCell) {
        let index = tableview.indexPath(for: tableviewcell)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: screenWidth - 40, kTextViewdHeight: 120 )
        let alert = SCLAlertView(appearance: appearance)
        let coachText = alert.addTextView()
        coachText.text = "this is a note from the coach"
        coachText.textColor = .lightGray
        coachText.textContainer.maximumNumberOfLines = 5
        coachText.textContainer.lineBreakMode = .byTruncatingTail
        coachText.isScrollEnabled = false
        coachText.isUserInteractionEnabled = false
        coachText.layer.cornerRadius = 6
        let selectedWorkoutExercises = viewModel.selectedWorkout?.exercises![index!.section] as! exercise
        if let note = selectedWorkoutExercises.note {
            coachText.textColor = .black
            coachText.text = note
        }
        
        alert.showInfo("Exercise note", subTitle: "Notes for this exercise from your coach.", closeButtonTitle: "close")
        
    }
    
    func completedCell(on tableviewcell: UITableViewCell, on item: Int, sender: UIButton, with cell:UICollectionViewCell) {
        let indexSection = tableview.indexPath(for: tableviewcell)
        
        viewModel.updateCompletedSet(at: IndexPath(item: item, section: indexSection!.section))
        
        
        sender.setImage(UIImage(named: "tickRing"), for: .normal)
        sender.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5) {
            cell.backgroundColor = UIColor.green
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                cell.backgroundColor = Constants.darkColour
            } completion: { (_) in
                let collection = cell.superview as! UICollectionView
                let lastindextoscroll = collection.numberOfItems(inSection: 0) - 1
                if item < lastindextoscroll{
                    let indextoscroll = IndexPath.init(row: item + 1, section: 0)
                    collection.scrollToItem(at: indextoscroll, at: .left, animated: true)
                }
            }

        }
    }
}

extension DisplayWorkoutViewController: LiveWorkoutAddMethods {
    func addSet(_ cell: UITableViewCell) {
        guard let section = self.tableview.indexPath(for: cell) else {return}
        let exercise = viewModel.getData(at: section) as! exercise
        let coordinator = coordinator as! LiveWorkoutCoordinator
        coordinator.addSet(exercise)
        
    }
    
    func addExercise() {
        guard let newExercise = exercise() else {return}
        let coordinator = coordinator as! LiveWorkoutCoordinator
        coordinator.addExercise(newExercise)
    }
}

extension DisplayWorkoutViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        BottomViewPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: - Methods for bottom views
extension DisplayWorkoutViewController: UITableViewDelegate {
    
    @objc func addToWorkouts() {
        viewModel.addToWorkouts()
        DisplayTopView.displayTopView(with: "Added to Workouts", on: self)
    }
    
    @objc func addToSavedWorkouts() {
        viewModel.addToSavedWorkouts()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if DisplayWorkoutViewController.selectedWorkout.creatorID == self.viewModel.userId {
                DisplayTopView.displayTopView(with: "Your Workout", on: self)
            } else {
                UserIDToUser.transform(userID: (DisplayWorkoutViewController.selectedWorkout.creatorID)) { user in
                    guard let coordinator = self.coordinator as? WorkoutCoordinatorFlow else {return}
                    coordinator.showUser(with: user)
                }
            }
        }
    }
}
