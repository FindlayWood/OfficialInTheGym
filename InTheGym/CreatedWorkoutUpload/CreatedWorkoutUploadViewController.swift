//
//  CreatedWorkoutUploadViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 08/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreatedWorkoutUploadViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator:UIActivityIndicatorView!
    @IBOutlet weak var collection:UICollectionView!
    
    let haptic = UINotificationFeedbackGenerator()
    
    var noOfExercises:Int!
    var createdFor:String!
    var workoutTitle:String!
    
    // is this workout for a group
    var groupBool:Bool!
    
    // number of times to upload the workout
    var stepCount:Int!
    
    // the workout to upload
    var createdWorkout:workout!
    
    
    var isPrivate:Bool = false
    var addToSaved:Bool = true
    var addToCreated:Bool = true
    var postToTimeline:Bool = true
    
    var adapter : CreatedWorkoutUploadAdapter!

    lazy var viewModel : CreatedWorkoutUploadViewModel = {
        return CreatedWorkoutUploadViewModel(createdFor: createdFor, noOfExercises: noOfExercises, group:groupBool)
    }()
    
    // feedback
    let selection = UISelectionFeedbackGenerator()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = CreatedWorkoutUploadAdapter(delegate: self)
        collection.delegate = adapter
        collection.dataSource = adapter
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collection.collectionViewLayout = layout
        collection.register(UINib(nibName: "UploadWorkoutOneCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UploadCellOne")
        collection.register(UINib(nibName: "UploadWorkoutTwoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UploadCellTwo")

        haptic.prepare()
        selection.prepare()
        
        initUI()
        initBarButton()
        initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    func initUI(){
        self.navigationItem.title = "Upload Workout"
    }
    
    func initBarButton(){
        let uploadButton = UIBarButtonItem(title: "UPLOAD", style: .plain, target: self, action: #selector(uploadWorkout))
        self.navigationItem.rightBarButtonItem = uploadButton
    }

    func initViewModel(){
        viewModel.collectionReloaded = { [weak self] () in
            DispatchQueue.main.async {
                self?.collection.reloadData()
            }
        }
        
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            let isLoading = self?.viewModel.isLoading
            if isLoading! {
                self?.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2) {
                    self?.collection.alpha = 0.0
                }
            } else {
                self?.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self?.collection.alpha = 1.0
                }
            }
        }
        
        viewModel.fetchData()
    }
    
    @objc func uploadWorkout(){
        haptic.notificationOccurred(.success)
        viewModel.uploadPost(with: createdWorkout, addToSaved: addToSaved, addToCreated: addToCreated, postToTimeline: postToTimeline, isPrivate: isPrivate, stepCount: stepCount)
        viewModel.updateWorkoutsCreated()
        DisplayTopView.displayTopView(with: "Workout Uploaded", on: self)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        
    }
    

}

extension CreatedWorkoutUploadViewController : CreatedWorkoutUploadDelegate {
    func getData(at indexPath: IndexPath) -> [String : AnyObject] {
        viewModel.getData(at: indexPath)
    }
    
    func itemSelected(at indexPath: IndexPath) {
        selection.selectionChanged()
        switch indexPath.item {
        case 2:
            viewModel.changePrivacy(isPrivate: isPrivate)
            isPrivate.toggle()
        case 3:
            viewModel.changeSaved(isSaved: addToSaved)
            addToSaved.toggle()
        case 4:
            viewModel.changeCreated(isCreated: addToCreated)
            addToCreated.toggle()
        case 5:
            viewModel.changePosting(isPosting: postToTimeline)
            postToTimeline.toggle()
        default:
            break
        }
    }
    
    func retreiveNumberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    
    
}
