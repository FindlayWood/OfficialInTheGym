//
//  WorkoutCompletedViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 01/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import SCLAlertView

class WorkoutCompletedViewController: UIViewController {
    
    @IBOutlet weak var collection:UICollectionView!
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    
    @IBOutlet weak var workoutRPE:UITextField!
    
    var workout : workout!
    
    var secondsToComplete : Int = 3400
    var timeString : String = "56m 32s"
    
    var averageRPE : Double = 8.2
    
    var isPrivateVar : Bool = false
    
    var adapter : WorkoutCompletedAdapter!
    
    lazy var viewModel : WorkoutCompletedViewModel = {
        return WorkoutCompletedViewModel(time: timeString, rpe: averageRPE)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        adapter = WorkoutCompletedAdapter(delegate: self)
        collection.delegate = adapter
        collection.dataSource = adapter
        collection.register(UINib(nibName: "WorkoutPrivacyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutPrivacyCollectionViewCell")
        collection.register(UINib(nibName: "WorkoutCompletedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WorkoutCompletedCollectionViewCell")
        collection.isUserInteractionEnabled = true
        //let itemSize = UIScreen.main.bounds.width/2 - 30

        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        //layout.itemSize = CGSize(width: itemSize, height: 100)

        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10

        collection.collectionViewLayout = layout
        
        initUI()
        initViewModel()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    func initUI(){
        self.navigationItem.title = "Summary"
        self.workoutRPE.layer.borderWidth = 1
        self.workoutRPE.layer.cornerRadius = 10
        self.workoutRPE.layer.borderColor = UIColor.black.cgColor
        self.workoutRPE.layer.masksToBounds = true
    }
    
    func initViewModel(){
        viewModel.dataDidLoadClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.collection.reloadData()
            }
            
        }
        
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collection.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.collection.alpha = 1.0
                    })
                }
            }
            
        }
        
        viewModel.fetchData()
    }
    
    func showError(){
        let alert = SCLAlertView()
        alert.showError("Enter Workout RPE", subTitle: "Enter a score between 1 and 10 to complete the workout.")
    }

    
    
    @IBAction func upload(_ sender:UIButton) {
        if workoutRPE.text == ""{
            showError()
        } else if Int(workoutRPE.text!)! > 10 || Int(workoutRPE.text!)! < 1{
            showError()
        } else {
            let rpeInt : Int = Int(workoutRPE.text!)!
            let workload : Int = (secondsToComplete/60) * rpeInt
            workout.score = rpeInt
            workout.timeToComplete = timeString
            workout.workload = workload
            
            if workout.fromDicover! {
                // update discover stats
                viewModel.updateDiscoverStats(for: workout, with: rpeInt, and: self.secondsToComplete)
            }

            if workout.assigned! {
                // update coach stats
                // creator id = coach
                viewModel.updateCoachScores(for: workout, with: rpeInt, to: workout.creatorID)
            }

            if !workout.liveWorkout {
                // means it has savedid, therfor update saved stats
                viewModel.updateDiscoverStats(for: workout, with: rpeInt, and: self.secondsToComplete)
            }

            viewModel.uploadActivityToCoaches(for: workout, with: rpeInt)
            viewModel.updateNumberOfCompletes()
            viewModel.updateSelfScores(for: workout, with: rpeInt)
            viewModel.updateWorkload(with: workout, workload: workload)
            viewModel.uploadPost(with: workout, privacy: isPrivateVar)
            viewModel.completeWorkout(for: workout, with: secondsToComplete)
            self.uploadedView()
        }
    }
    
    func changePrivacy(){
        switch isPrivateVar {
        case true:
            self.isPrivateVar = false
        case false:
            self.isPrivateVar = true
        }
        self.collection.reloadItems(at: [IndexPath(item: 2, section: 0)])
    }
    
    func uploadedView(){
        let showView = UIView()
        showView.backgroundColor = .white
        self.view.addSubview(showView)
        showView.frame = view.frame
        let label = UILabel()
        label.text = "Great Work!"
        label.font = UIFont(name: "Menlo-Bold", size: 25)
        label.textColor = .black
        showView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: showView.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: showView.centerYAnchor).isActive = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showView.removeFromSuperview()
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        }
    }
    
    
}

extension WorkoutCompletedViewController : WorkoutCompletedProtocol {
    func getData(at indexPath: IndexPath) -> [String : AnyObject] {
        return viewModel.getData(at: indexPath)
    }
    
    func isPrivate() -> Bool {
        return isPrivateVar
    }
    
    func itemSelected(at indexPath: IndexPath) {
        if indexPath.item == 2 {
            self.changePrivacy()
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    func retreiveNumberOfSections() -> Int {
        return 1
    }
    
    
}
