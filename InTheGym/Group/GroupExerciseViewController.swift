//
//  GroupExerciseViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/04/2020.
//  Copyright © 2020 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class GroupExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    
    //varibale from previous page on type of exercise
    var exerciseType: String = ""
    
    //array to hold list of exercises
    var exerciseList = [String]()
    
    //outlet to tableview
    @IBOutlet weak var tableview:UITableView!
    
    //database reference
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
        
    }
    
    
    
    //loading the tableview
    //number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if search bar is active
        if isFiltering{
            return searchResults.count
        }else{
            return exerciseList.count
        }
    }
    
    //display of row
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
    
    //selecting a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let SVC = StoryBoard.instantiateViewController(withIdentifier: "GroupSetsViewController") as! GroupSetsViewController
        
        if exerciseType == "Cardio"{
            if searchController.isActive{
                SVC.exercise = searchResults[indexPath.row]
            }else{
                SVC.exercise = exerciseList[indexPath.row]
            }
            SVC.type = "cardio"
        }
        
        else{
            if searchController.isActive{
                SVC.exercise = searchResults[indexPath.row]
            }else{
                SVC.exercise = exerciseList[indexPath.row]
            }
        }
        
        self.navigationController?.pushViewController(SVC, animated: true)
        
    }
    
    //load the correct exercises from database to tableview
    func loadExercises(bodyType: String){
        exerciseList.removeAll()
        DBRef.child(bodyType).observe(.childAdded) { (snapshot) in
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
           // If the search bar contains text, filter our data with the string
           if let searchText = searchController.searchBar.text {
               filterContent(for: searchText)
               // Reload the table view with the search result data.
               tableview.reloadData()
           }
       }
    
    

}
