//
//  SavedWorkoutsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/09/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//
// this page is not for saved workouts
// it is for the new implementation of sets page
// it asks the user for how many sets on an exercise
// and then passes onto the new implementation of reps page

import UIKit
import SCLAlertView

class ExerciseSetsViewController: UIViewController, Storyboarded {
    
    weak var coordinator: RegularAndCircuitFlow?
    var newExercise: exercise?
    
    //collection to display number options
    lazy var collection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
        collection.backgroundColor = .white
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    lazy var setLabel: UILabel = {
       let label = UILabel()
        label.text = "1"
        label.textColor = Constants.darkColour
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 200, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var plusButton: UIButton = {
       let button = UIButton()
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.addTarget(self, action: #selector(plus), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var minusButton: UIButton = {
       let button = UIButton()
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 120, weight: .bold)
        button.backgroundColor = .clear
        button.setTitleColor(Constants.darkColour, for: .normal)
        button.addTarget(self, action: #selector(minus), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("NEXT", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24, weight: .bold)
        button.backgroundColor = Constants.darkColour
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 22.5
        button.addTarget(self, action: #selector(nextPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var pageNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = Constants.darkColour
        label.font = UIFont(name: "Menlo-Bold", size: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private var setNumber: Int = 1
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Sets"
        
        view.addSubview(setLabel)
        view.addSubview(minusButton)
        view.addSubview(plusButton)
        view.addSubview(collection)
        view.addSubview(nextButton)
        view.addSubview(pageNumberLabel)
        collection.delegate = self
        collection.dataSource = self
        collection.register(SetsCell.self, forCellWithReuseIdentifier: "cell")
        
        switch coordinator{
        case is RegularWorkoutCoordinator:
            pageNumberLabel.text = "3 of 6"
        case is CircuitCoordinator:
            pageNumberLabel.text = "3 of 5"
        default:
             break
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = Constants.lightColour
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSLayoutConstraint.activate([setLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     setLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                                     
                                     minusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                                     minusButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     
                                     plusButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
                                     plusButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
                                     collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     collection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     collection.topAnchor.constraint(equalTo: setLabel.bottomAnchor, constant: 10),
                                     collection.heightAnchor.constraint(equalToConstant: 100),
        
                                     nextButton.topAnchor.constraint(equalTo: collection.bottomAnchor, constant: 10),
                                     nextButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                                     nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                                     nextButton.heightAnchor.constraint(equalToConstant: 45),
        
                                     pageNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     pageNumberLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    
    func generateLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.itemSize = CGSize(width: 80, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.scrollDirection = .horizontal
        return layout
    }
}

extension ExerciseSetsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 21
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SetsCell
        cell.numberLabel.text = (indexPath.item + 1).description
        if (indexPath.item + 1) == setNumber {
            cell.backgroundColor = Constants.darkColour
        } 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        setNumber = indexPath.item + 1
        setLabel.text = setNumber.description
        collection.reloadData()
        collection.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    @objc func plus() {
        if setNumber < 20 {
            setNumber += 1
            setLabel.text = setNumber.description
            collection.reloadData()
            collection.scrollToItem(at: IndexPath(item: setNumber - 1, section: 0), at: .centeredHorizontally, animated: true)
        }
        
    }
    
    @objc func minus() {
        if setNumber > 1 {
            setNumber -= 1
            setLabel.text = setNumber.description
            collection.reloadData()
            collection.scrollToItem(at: IndexPath(item: setNumber - 1, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func nextPressed() {
        guard let newExercise = newExercise else {return}
        newExercise.sets = setNumber
        let completedArray = Array(repeating: false, count: setNumber)
        newExercise.completedSets = completedArray
        coordinator?.setsSelected(newExercise)
    }
}
