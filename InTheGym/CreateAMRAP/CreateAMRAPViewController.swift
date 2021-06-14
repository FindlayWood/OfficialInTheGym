//
//  CreateAMRAPViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateAMRAPViewController: UIViewController {
    
    weak var coordinator: AMRAPCoordinator?
    
    static var exercises = [exercise]()
    var amrapTime: Int = 10
    var adapter: CreateAMRAPAdapter?
    var amrapView = CreateAMRAPView()
    var timeSelectedView = TimeSelectionView()
    var flashView = FlashView()
    
    private var bottomViewHeight = Constants.screenSize.height * 0.5

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finished))
        navigationItem.rightBarButtonItem = button
        navigationItem.rightBarButtonItem?.isEnabled = false
        //setup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        amrapView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom)
        view.addSubview(amrapView)
        setup()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.title = "Create AMRAP"
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor: Constants.darkColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.darkColour
        amrapView.tableview.reloadData()
        if CreateAMRAPViewController.exercises.count > 0 {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    

    
    func setup() {
        adapter = CreateAMRAPAdapter(delegate: self)
        amrapView.tableview.delegate = adapter
        amrapView.tableview.dataSource = adapter
        amrapView.tableview.register(AMRAPCell.self, forCellReuseIdentifier: "cell")
        amrapView.tableview.register(NewExerciseCell.self, forCellReuseIdentifier: "newCell")
        amrapView.timeNumberLabel.text = amrapTime.description + " mins"
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeTime))
        amrapView.timeView.addGestureRecognizer(tap)
    }

}

extension CreateAMRAPViewController {
    @objc func addExercise() {
        if CreateAMRAPViewController.exercises.count < 10 {
            guard let newAMRAPExercise = exercise() else {return}
            coordinator?.addExercise(newAMRAPExercise)
        }
    }
    
    @objc func finished() {
        var objectExercises = [[String:AnyObject]]()
        for ex in CreateAMRAPViewController.exercises {
            objectExercises.append(ex.toObject())
        }
        let amrapData = ["timeLimit": amrapTime,
                         "exercises": objectExercises] as [String:AnyObject]
        guard let amrapModel = AMRAP(data: amrapData) else {return}
        let amrapObject = amrapModel.toObject()
        AddWorkoutHomeViewController.exercises.append(amrapObject)
        DisplayTopView.displayTopView(with: "Added AMRAP", on: self)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

extension CreateAMRAPViewController: CreateAMRAPProtocol {
    func getData(at indexPath: IndexPath) -> exercise {
        return CreateAMRAPViewController.exercises[indexPath.section]
    }
    func addNewExercise() {
        addExercise()
    }
    func numberOfExercises() -> Int {
        return CreateAMRAPViewController.exercises.count + 1
    }
    @objc func changeTime() {
        timeSelectedView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: bottomViewHeight)
        flashView.frame = CGRect(x: 0, y: 0 - view.safeAreaInsets.top, width: view.frame.width, height: view.frame.height)
        flashView.alpha = 0
        amrapView.addSubview(flashView)
        amrapView.addSubview(timeSelectedView)
        timeSelectedView.delegate = self
        timeSelectedView.flashview = flashView
        let showFrame = CGRect(x: 0, y: Constants.screenSize.height - bottomViewHeight - view.safeAreaInsets.top, width: view.frame.width, height: bottomViewHeight)
        UIView.animate(withDuration: 0.2) {
            self.timeSelectedView.frame = showFrame
            self.flashView.alpha = 0.4
            self.flashView.isUserInteractionEnabled = true
        }
    }
    func timeSelected(newTime: Int) {
        amrapTime = newTime
        amrapView.timeNumberLabel.text = newTime.description + " mins"
    }
    func getTime() -> Int {
        return amrapTime
    }
}
