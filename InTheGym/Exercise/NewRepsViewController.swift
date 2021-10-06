//
//  NewRepsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 09/10/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

//this is the new reps page. it is used instead of repviewcontroller

import UIKit
import SCLAlertView

enum setSelected {
    case allSelected
    case singleSelected(Int)
}

class NewRepsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: CreationDelegate?
    var newExercise: exercise?
    
    var repView = RepsView()
    
    lazy var repIntArray: [Int] = {
        var array = [Int]()
        guard let newExercise = newExercise else {return []}
        array = Array(repeating: 1, count: newExercise.sets ?? 0)
        return array
    }()
    
    private var repCounter: Int = 1
    
    private var selectedState: setSelected = .allSelected
    private var topSelectedIndex: Int? = nil
    
    private var topAdapter: RepsTopCollectionAdapter!
    private var bottomAdapter: RepsBottomCollectionAdapter!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    
    var fromLiveWorkout:Bool!
    var whichExercise:Int!
    var workoutID:String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Reps"
  
        switch coordinator{
        case is CircuitCoordinator:
            repView.pageNumberLabel.text = "4 of 4"
        case is RegularWorkoutCoordinator:
            repView.pageNumberLabel.text = "4 of 6"
        case is LiveWorkoutCoordinator:
            repView.topCollection.isHidden = true
            repView.pageNumberLabel.text = "1 of 2"
        case is AMRAPCoordinator:
            repView.topCollection.isHidden = true
            repView.pageNumberLabel.text = "3 of 4"
        default:
            break
        }
        
        view.addSubview(repView)
        repView.translatesAutoresizingMaskIntoConstraints = false
        topAdapter = RepsTopCollectionAdapter(delegate: self)
        bottomAdapter = RepsBottomCollectionAdapter(delegate: self)
        repView.topCollection.delegate = topAdapter
        repView.topCollection.dataSource = topAdapter
        repView.bottomCollection.delegate = bottomAdapter
        repView.bottomCollection.dataSource = bottomAdapter
        repView.topCollection.register(RepsCell.self, forCellWithReuseIdentifier: "cell")
        repView.bottomCollection.register(SetsCell.self, forCellWithReuseIdentifier: "cell")
        repView.minusButton.addTarget(self, action: #selector(minus), for: .touchUpInside)
        repView.plusButton.addTarget(self, action: #selector(plus), for: .touchUpInside)
        repView.nextButton.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        initNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.lightColour
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([repView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     repView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     repView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     repView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    func initNavBar() {
        let nextButton = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextPressed))
        navigationItem.rightBarButtonItem = nextButton
    }
    
    func generateTopLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 160, height: 120)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func generateBottomLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

extension NewRepsViewController: repsTopCollectionProtocol {
    func getData(at index: IndexPath) -> Int {
        return repIntArray[index.item]
    }
    func retreiveNumberOfItems() -> Int {
        return repIntArray.count
    }
    func itemSelected(at indec: IndexPath) {
        switch selectedState{
        case .allSelected:
            selectedState = .singleSelected(indec.item)
            topSelectedIndex = indec.item
            repCounter = repIntArray[indec.item]
            if repCounter == 0 {
                repView.repLabel.text = "M"
            } else {
                repView.repLabel.text = repCounter.description
            }
            repView.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
            repView.bottomCollection.reloadData()
        case .singleSelected(let selectedIndex):
            if selectedIndex == indec.item {
                selectedState = .allSelected
                topSelectedIndex = nil
            } else {
                repCounter = repIntArray[indec.item]
                if repCounter == 0 {
                    repView.repLabel.text = "M"
                } else {
                    repView.repLabel.text = repCounter.description
                }
                selectedState = .singleSelected(indec.item)
                topSelectedIndex = indec.item
                repView.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
                repView.bottomCollection.reloadData()
            }
        }
        repView.topCollection.scrollToItem(at: IndexPath(item: indec.item, section: 0), at: .centeredHorizontally, animated: true)
        repView.topCollection.reloadData()
    }
    func selectedIndex() -> Int? {
        return topSelectedIndex
    }
}

extension NewRepsViewController: repsbottomCollectionProtocol {
    func selectedIndex() -> Int {
        return repCounter
    }
    func bottomItemSelected(at index: IndexPath) {
        if index.item == 0 {
            repView.repLabel.text = "M"
            repCounter = index.item
        } else {
            repCounter = index.item
            repView.repLabel.text = repCounter.description
        }
        
        switch selectedState {
        case .allSelected:
            repIntArray = repIntArray.map { _ in repCounter }
        case .singleSelected(let index):
            repIntArray[index] = repCounter
        }
        repView.bottomCollection.scrollToItem(at: IndexPath(item: index.item, section: 0), at: .centeredHorizontally, animated: true)
        repView.bottomCollection.reloadData()
        repView.topCollection.reloadData()
    }
}

//MARK: - button methods
extension NewRepsViewController{
    
    @objc func plus() {
        if repCounter < 99 {
            repCounter += 1
            repView.repLabel.text = repCounter.description
            switch selectedState{
            case .allSelected:
                repIntArray = repIntArray.map { _ in repCounter }
            case .singleSelected(let index):
                repIntArray[index] = repCounter
            }
            repView.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
            repView.bottomCollection.reloadData()
            repView.topCollection.reloadData()
        }
    }
    
    @objc func minus() {
        if repCounter == 1 {
            repView.repLabel.text = "M"
            repCounter -= 1
        }else if repCounter > 1 {
            repCounter -= 1
            repView.repLabel.text = repCounter.description
        }
        switch selectedState {
        case .allSelected:
            repIntArray = repIntArray.map { _ in repCounter }
        case .singleSelected(let index):
            repIntArray[index] = repCounter
        }
        repView.bottomCollection.scrollToItem(at: IndexPath(item: repCounter, section: 0), at: .centeredHorizontally, animated: true)
        repView.bottomCollection.reloadData()
        repView.topCollection.reloadData()
    }
    
    @objc func nextPressed() {
        guard let newExercise = newExercise else {return}
        if coordinator is LiveWorkoutCoordinator {
            newExercise.repArray?.append(repCounter)
        } else if coordinator is AMRAPCoordinator || coordinator is EMOMCoordinator {
            newExercise.reps = repCounter
        } else {
            newExercise.repArray = repIntArray
        }
        coordinator?.repsSelected(newExercise)
    }
}
