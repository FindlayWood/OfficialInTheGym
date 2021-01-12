//
//  SearchForUsersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 06/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase
import EmptyDataSet_Swift

class SearchForUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, EmptyDataSetSource, EmptyDataSetDelegate  {

    
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var searchBar:UITextField!
    
    //database reference
    var DBRef :DatabaseReference!
    
    // list to contain users
    var users : [Users] = []
    
    
    
    // variables for search bar
    // An empty tuple that will be updated with search results.
    var searchResults : [Users] = []
    // search bar
    let searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    var headerHeight: CGFloat = 10.0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        // Place the search bar in the table view's header.
        self.tableview.tableHeaderView = searchController.searchBar
        
        self.tableview.emptyDataSetSource = self
        self.tableview.emptyDataSetDelegate = self
        self.tableview.tableFooterView = UIView()
        
        let user1 = Users()
        user1.firstName = "Lebron"
        user1.lastName = "James"
        user1.username = "KingJames"
        
        let user2 = Users()
        user2.firstName = "Dwayne"
        user2.lastName = "Johnson"
        user2.username = "The Rock"
        
        let user3 = Users()
        user3.firstName = "Mark"
        user3.lastName = "Wahlberg"
        user3.username = "Juice Head"
        
        //self.users = [user1, user2, user3]
        loadUsers()
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // if search bar is active
        if isFiltering{
            return searchResults.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SearchUsersTableViewCell
        cell.profileImage.image = UIImage(named: "player_icon")
        cell.fullName.text = searchResults[indexPath.section].firstName! + " " + searchResults[indexPath.section].lastName!
        if isFiltering{
            cell.username.text = searchResults[indexPath.section].username
            if searchResults[indexPath.section].admin!{
                cell.profileImage.image = UIImage(named: "coach_icon")
            }
        }else{
            cell.username.text = users[indexPath.row].username
        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "PublicProfileViewController") as! PublicProfileViewController
        nextVC.user = searchResults[indexPath.section]
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    // space in between sections
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let background = UILabel()
        background.backgroundColor = Constants.lightColour
        return background
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Search for other Users"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the search bar above and begin typing to discover other users."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
    // for search bar
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our entries based on the title value.
        
        
        searchResults = users.filter {($0.username?.lowercased().contains(searchText.lowercased()))!
                                        || ($0.firstName?.lowercased().contains(searchText.lowercased()))!
                                        || ($0.lastName?.lowercased().contains(searchText.lowercased()))!
        }
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
    
    func loadUsers(){
        var initialLoad = true
        let userReference = Database.database().reference().child("users")
        userReference.observe(.childAdded, with: { (snapshot) in
            
            if let snap = snapshot.value as? [String:AnyObject]{
                let newUser = Users()
                newUser.username = snap["username"] as? String
                newUser.firstName = snap["firstName"] as? String ?? "no"
                newUser.lastName = snap["lastName"] as? String ?? "name"
                newUser.admin = snap["admin"] as? Bool ?? false
                newUser.uid = snapshot.key
                self.users.append(newUser)
            }
            
            if initialLoad == false{
                print("not yet decided...")
            }
            
            
        }, withCancel: nil)
        
        userReference.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
            print("loaded users")
            print(self.users)
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }


}
