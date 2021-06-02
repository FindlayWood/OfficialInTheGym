//
//  ExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/07/2019.
//  Copyright © 2019 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, Storyboarded {
    
    weak var coordinator: CreationDelegate?
    var newExercise: exercise?
    var bodyTypeEnum: bodyType?
    
    var fromLiveWorkout:Bool!
    let userID = Auth.auth().currentUser!.uid
    var workoutID:String!
    
    var exerciseType: String = ""
    var exerciseList = [String]()
    @IBOutlet weak var tableview:UITableView!
    
    @IBOutlet weak var pageNumberLabel:UILabel!
    
    var DBRef:DatabaseReference!
    
    // variables for search bar
    // An empty tuple that will be updated with search results.
    var searchResults : [String] = []
    // search bar
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Exercise"

        DBRef = Database.database().reference().child("Exercises")
        
        self.tableview.rowHeight = 65
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        // Place the search bar in the table view's header.
        self.tableview.tableHeaderView = searchController.searchBar

        // Set the content offset to the height of the search bar's height
        // to hide it when the view is first presented.
        //self.tableview.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
        
        if fromLiveWorkout == true{
            pageNumberLabel.text = "2 of 2"
        }else{
            pageNumberLabel.text = "2 of 6"
        }
        
        switch coordinator{
        case is RegularWorkoutCoordinator:
            pageNumberLabel.text = "2 of 6"
        case is CircuitCoordinator:
            pageNumberLabel.text = "2 of 4"
        case is LiveWorkoutCoordinator:
            pageNumberLabel.text = "2 of 2"
        default:
             break
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // if search bar is active
        if isFiltering{
            return searchResults.count
        }else{
            return exerciseList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.textColor = .darkGray
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        if isFiltering{
            cell.textLabel?.text = searchResults[indexPath.row]
        }else{
            cell.textLabel?.text = exerciseList[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var globalType:String = ""
        var globalExercise:String = ""
        
        switch self.exerciseType {
        case "Upper Body":
            globalType = "UB"
        case "Lower Body":
            globalType = "LB"
        case "Core":
            globalType = "CO"
        case "Cardio":
            globalType = "CA"
        default:
            globalType = "UB"
        }
        
        if searchController.isActive{
            globalExercise = searchResults[indexPath.row]
        }else{
            globalExercise = exerciseList[indexPath.row]
        }
        
        if fromLiveWorkout == true{
            

            
            //let backto = WorkoutDetailViewController()
            let exerciseData = ["exercise":globalExercise,
                                "type": globalType,
                                "sets": "0",
                                "reps": "",
                                "weight":""] as [String:AnyObject]
            WorkoutDetailViewController.exercises.append(exerciseData)
            let updateRef = Database.database().reference().child("Workouts").child(self.userID).child(self.workoutID)
            updateRef.updateChildValues(["exercises":WorkoutDetailViewController.exercises])

            
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)

        }else{
            guard let newExercise = newExercise else {return}
            newExercise.exercise = globalExercise
            coordinator?.exerciseSelected(newExercise)
//            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            let SVC = StoryBoard.instantiateViewController(withIdentifier: "ExerciseSetsViewController") as! ExerciseSetsViewController
            

            
//            if searchController.isActive{
//                SVC.exercise = searchResults[indexPath.row]
//            }else{
//                SVC.exercise = exerciseList[indexPath.row]
//            }

//            SVC.type = globalType
//            SVC.exercise = globalExercise
//
//            self.navigationController?.pushViewController(SVC, animated: true)
        }
        
        
    }
    
    func loadExercises(bodyType: String){
        exerciseList.removeAll()
        guard let type = newExercise?.type?.rawValue else {
            return
        }
        DBRef.child(type).observe(.childAdded) { (snapshot) in
            if let snap = snapshot.value as? String{
                self.exerciseList.append(snap)
                self.tableview.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadExercises(bodyType: exerciseType)
        navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor:#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    // for search bar
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our entries based on the title value.
        searchResults = exerciseList.filter({ (String) -> Bool in
            let match = String.range(of: searchText, options: .caseInsensitive)
            // Return the tuple if the range contains a match.
            return match != nil
           })
       }

       // MARK: - UISearchResultsUpdating method
       
       func updateSearchResults(for searchController: UISearchController) {
           // If the search bar contains text, filter out data with the string
           if let searchText = searchController.searchBar.text {
               filterContent(for: searchText)
               // Reload the table view with the search result data.
               tableview.reloadData()
           }
       }
    

}
