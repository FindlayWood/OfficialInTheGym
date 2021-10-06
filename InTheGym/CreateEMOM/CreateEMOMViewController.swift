//
//  CreateEMOMViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateEMOMViewController: UIViewController {
    
    weak var coordinator: EMOMCoordinator?
    
    var display = CreateEMOMView()
    
    var adapter: CreateEMOMAdapter!
    
    var viewModel = CreateEMOMViewModel()
    
    static var exercises = [exercise]()
    
    var EMOMTime: Int = 10 {
        didSet {
            display.timeNumberLabel.text = EMOMTime.description + " mins"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        initDisplay()
        initNavBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        editNavBarColour(to: .darkColour)
        navigationItem.title = viewModel.navigationTitle
        display.tableview.reloadData()
        if CreateEMOMViewController.exercises.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func initDisplay() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        if #available(iOS 15.0, *) {
            display.tableview.sectionHeaderTopPadding = 0
        }
        display.timeNumberLabel.text = EMOMTime.description + " mins"
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTime))
        display.timeView.addGestureRecognizer(tap)
    }
    
    func initNavBar() {
        let barButton = UIBarButtonItem(title: "Finished", style: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = barButton
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    @objc func finished() {
        var objectExercises = [[String:AnyObject]]()
        for ex in CreateEMOMViewController.exercises {
            objectExercises.append(ex.toObject())
        }
        let emomTimeLimit = EMOMTime * 60
        let emomData = ["timeLimit": emomTimeLimit,
                         "exercises": objectExercises] as [String:AnyObject]
        guard let emomModel = EMOM(data: emomData) else {return}
        let emomObject = emomModel.toObject()
        AddWorkoutHomeViewController.exercises.append(emomObject)
        DisplayTopView.displayTopView(with: "Added EMOM", on: self)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        CreateEMOMViewController.exercises.removeAll()
        EMOMTime = 10
    }
    
    @objc func changeTime() {
        coordinator?.showTimePicker(with: self, time: EMOMTime)
    }
}

extension CreateEMOMViewController: CreateEMOMProtocol {
    func numberOfExercises() -> Int {
        return CreateEMOMViewController.exercises.count + 1
        //return viewModel.numberOfExercises
    }
    
    func getData(at indexPath: IndexPath) -> exercise {
        return CreateEMOMViewController.exercises[indexPath.section]
        //return viewModel.getData(at: indexPath)
    }
    
    func addNewExercise() {
        guard let newEMOMExercise = exercise() else {return}
        coordinator?.addExercise(newEMOMExercise)
    }
}

extension CreateEMOMViewController: TimeSelectionParentDelegate {
    func timeSelected(newTime: Int) {
        EMOMTime = newTime
    }
}
