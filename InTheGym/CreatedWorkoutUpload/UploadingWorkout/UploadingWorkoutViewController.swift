//
//  UploadingWorkoutViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 22/08/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class UploadingWorkoutViewController: UIViewController {
    
    weak var coordinator: UploadingCoordinator?

    var display = UploadingWorkoutView()
    
    var viewModel = UploadingWorkoutViewModel()
    
    var adapter: UploadingWorkoutAdapter!
    
    var workoutToUpload: UploadableWorkout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initViewModel()
        initBarButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    override func viewWillAppear(_ animated: Bool) {
        editNavBarColour(to: .darkColour)
        navigationItem.title = "Uploading"
    }
    func initBarButton() {
        let rightBarButton  = UIBarButtonItem(title: "Upload", style: .done, target: self, action: #selector(uploadWorkout))
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func initDisplay() {
        adapter = .init(delegate: self)
        display.collectionView.delegate = adapter
        display.collectionView.dataSource = adapter
        display.configure(with: workoutToUpload)
        let workoutTap = UITapGestureRecognizer(target: self, action: #selector(showWorkout))
        display.workoutView.addGestureRecognizer(workoutTap)
        let assigneeTap = UITapGestureRecognizer(target: self, action: #selector(showAssignee))
        display.assigneeView.addGestureRecognizer(assigneeTap)
    }
    func initViewModel() {
        viewModel.reloadCollectionView = { [weak self] in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.display.collectionView.reloadData()
            }
        }
    }

}

extension UploadingWorkoutViewController: UploadingWorkoutProtocol {
    func getData(at indexPath: IndexPath) -> UploadCellModelProtocol {
        return viewModel.getData(at: indexPath)
    }
    func numberOfItems() -> Int {
        return viewModel.numberOfItems
    }
    func itemSelected(at indexPath: IndexPath) {
        
    }
    func savingSwitchChanged() {
        
    }
    func privacyChanged() {
        
    }
}

extension UploadingWorkoutViewController {
    @objc func showWorkout() {
        coordinator?.showWorkout(with: workoutToUpload.workout)
    }
    @objc func showAssignee() {
        if workoutToUpload.assignee is Users {
            if workoutToUpload.assignee.uid != FirebaseAuthManager.currentlyLoggedInUser.uid {
                coordinator?.showUser(user: workoutToUpload.assignee as! Users)
            }
        }
    }
    @objc func uploadWorkout() {
        
    }
}
