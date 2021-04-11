//
//  DisplaySavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class DisplayWorkoutViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    
    var selectedWorkout : WorkoutDelegate!
    
    var adapter : DisplayWorkoutAdapter!
    
    var workoutHasBegun : Bool?
    
    lazy var viewModel: DisplayWorkoutViewModel = {
        return DisplayWorkoutViewModel(workout: selectedWorkout)
    }()
    
    // array of colours to set rpe button
    let colors = [#colorLiteral(red: 0, green: 0.5, blue: 1, alpha: 1), #colorLiteral(red: 0.6332940925, green: 0.8493953339, blue: 1, alpha: 1), #colorLiteral(red: 0.7802333048, green: 1, blue: 0.5992883134, alpha: 1), #colorLiteral(red: 0.9427440068, green: 1, blue: 0.3910798373, alpha: 1), #colorLiteral(red: 1, green: 1, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.8438837757, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.7074058219, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.4706228596, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0.3134631849, blue: 0, alpha: 1), #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = DisplayWorkoutAdapter(delegate: self)
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.tableFooterView = UIView()
        tableview.rowHeight = 380
        tableview.register(UINib(nibName: "DisplayWorkout", bundle: nil), forCellReuseIdentifier: "DisplayWorkoutCell")
        tableview.register(UINib(nibName: "DisplayPlusTableView", bundle: nil), forCellReuseIdentifier: "DisplayPlusTableView")
        
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
    }
    
    func initUI(){
        navigationItem.title = selectedWorkout.title
    }
    
    func initBottomView(){
        switch selectedWorkout {
        case is publicSavedWorkout:
            // function to increase the views by 1
            let bv = SavedWorkoutBottomView(workout: selectedWorkout, parent: self.view)
            bv.bottomViewSetUpClosure = { [weak self] () in
                self?.viewModel.addToWorkouts()
                DisplayTopView.displayTopView(with: "Added To Workouts", on: self!)
                // fucntion to add workout on viewmodel
            }
        case is privateSavedWorkout:
            let bv = SavedWorkoutBottomView(workout: selectedWorkout, parent: self.view)
            bv.bottomViewSetUpClosure = { [weak self] () in
                self?.viewModel.addToWorkouts()
                DisplayTopView.displayTopView(with: "Added To Workouts", on: self!)
                // fucntion to add workout on viewmodel
            }
        case is discoverWorkout:
            if !selectedWorkout.liveWorkout {
                let bv = DiscoverWorkoutBottomView(workout: selectedWorkout, parent: self.view)
                bv.bottomViewSetUpClosure = { [weak self] () in
                    //add to saved workouts
                    self?.viewModel.addToSavedWorkouts()
                    print("adding to saved workouts")
                }
            }
            
        case is workout:
            if selectedWorkout.completed{
                // no view
            }else{
                let bv = MainWorkoutBottomView(workout: selectedWorkout, parent: self.view)
                self.view.addSubview(bv)
                bv.bottomViewSetUpClosure = { [weak self] () in
                    self?.tableview.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    print("loaded and ready to go")
                    self?.viewModel.startTheWorkout()
                }
            }
        default:
            print("there is no need for any views")
        }
    }
    
    func loadTableview(){
        viewModel.selectedWorkout = self.selectedWorkout
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
        
        viewModel.setup()
        
    }
    
    func showError(){
        // show alertview error
    }
    
}
extension DisplayWorkoutViewController: DisplayWorkoutProtocol{
    
    func getData(at: IndexPath) -> exercise {
        return self.viewModel.getData(at: at)
    }
    
    func isLive() -> Bool {
        return self.viewModel.isLive()
    }
    
    func itemSelected(at: IndexPath) {
        if isLive() && at.section == viewModel.numberOfItems{
            // here have viewmodel method to send to next page
            // which will be body type page
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
        switch selectedWorkout {
        case is publicSavedWorkout:
            return false
        case is privateSavedWorkout:
            return false
        case is liveWorkout:
            return true
        case is discoverWorkout:
            return false
        case is workout:
            let s = selectedWorkout as! workout
            if selectedWorkout.completed {
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
                //WorkoutDetailViewController.exercises[index.section]["rpe"] = rpe.text as AnyObject?
                //print(WorkoutDetailViewController.exercises[index.section])
                //self.DBRef.child(self.workoutID).updateChildValues(["exercises" : WorkoutDetailViewController.exercises])
                //let cellIndex = IndexPath.init(row: 0, section: index.section)
                //let row = self.tableview.cellForRow(at: index!)
                UIView.animate(withDuration: 0.5) {
                    tableviewcell.backgroundColor = self.colors[colourIndex]
                    collection.backgroundColor = self.colors[colourIndex]
                    
                    //sender.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
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
        
        // add call to viewmodel function to update database
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
        if let note = viewModel.selectedWorkout?.exercises![index!.section].note{
            coachText.textColor = .black
            coachText.text = note
        }else{
            coachText.text = "no note from coach"
        }
        
        alert.showInfo("Exercise note", subTitle: "Notes for this exercise from your coach.", closeButtonTitle: "close")
        
    }
    
    func completedCell(on tableviewcell: UITableViewCell, on item: Int, sender: UIButton, with cell:UICollectionViewCell) {
        let indexSection = tableview.indexPath(for: tableviewcell)
        
        viewModel.updateCompletedSet(at: IndexPath(item: item, section: indexSection!.section))
        
        
        sender.setImage(UIImage(named: "tickRing"), for: .normal)
        
        UIView.animate(withDuration: 0.5) {
            cell.backgroundColor = UIColor.green
        } completion: { (_) in
            UIView.animate(withDuration: 0.5) {
                cell.backgroundColor = Constants.lightColour
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
