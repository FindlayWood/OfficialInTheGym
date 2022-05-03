//  SearchForUsersViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//


import UIKit
import Firebase
import CodableFirebase

class SearchForUsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, Storyboarded  {

    
    
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
    
    let userID = Auth.auth().currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        self.definesPresentationContext = true

        // Place the search bar in the table view's header.
        self.tableview.tableHeaderView = searchController.searchBar
        
        self.tableview.tableFooterView = UIView()
        
        tableview.rowHeight = UITableView.automaticDimension
        tableview.estimatedRowHeight = 90
        loadUsers()
        
        navigationItem.title = "Discover"
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // if search bar is active
        if isFiltering{
            return searchResults.count
        }else{
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "cell") as! SearchUsersTableViewCell
        //cell.profileImage.image = UIImage(named: "player_icon")
        cell.fullName.text = searchResults[indexPath.row].firstName + " " + searchResults[indexPath.row].lastName
        cell.profileImage.layer.cornerRadius = cell.profileImage.bounds.width / 2.0
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.borderColor = Constants.darkColour.cgColor
        cell.username.text = "@" + searchResults[indexPath.row].username
        
        let usersID = searchResults[indexPath.row].uid
        ImageAPIService.shared.getProfileImage(for: usersID) { (image) in
            if let image = image {
                cell.profileImage.image = image
            }
        }
        cell.userBio.text = searchResults[indexPath.row].profileBio
//        if let profileBio = searchResults[indexPath.row].profileBio {
//            cell.userBio.text = profileBio
//        }else{
//            cell.userBio.text = ""
//        }
 
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "PublicTimelineViewController") as! PublicTimelineViewController
        nextVC.viewModel.user = searchResults[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    
    // for search bar
    
    func filterContent(for searchText: String) {
        // Update the searchResults array with matches
        // in our entries based on the title value.
        
        
        searchResults = users.filter {($0.username.lowercased().contains(searchText.lowercased()))
                                        || ($0.firstName.lowercased().contains(searchText.lowercased()))
                                        || ($0.lastName.lowercased().contains(searchText.lowercased()))
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
            guard let snap = snapshot.value as? [String:AnyObject] else {return}
            if snapshot.key != FirebaseAuthManager.currentlyLoggedInUser.uid {
                do {
                    let user = try FirebaseDecoder().decode(Users.self, from: snap)
                    self.users.append(user)
                }
                catch {
                    print(error.localizedDescription)
                }
            }

            
//            if snapshot.key == self.userID!{
//                return
//            }else{
//                if let snap = snapshot.value as? [String:AnyObject]{
//                    var newUser: Users!
//                    newUser.username = snap["username"] as? String ?? "username"
//                    newUser.firstName = snap["firstName"] as? String ?? "no"
//                    newUser.lastName = snap["lastName"] as? String ?? "name"
//                    newUser.admin = snap["admin"] as? Bool ?? false
//                    newUser.uid = snapshot.key
//                    newUser.profilePhotoURL = snap["profilePhotoURL"] as? String ?? "nil"
//                    newUser.profileBio = snap["profileBio"] as? String ?? ""
//                    self.users.append(newUser)
//                }
//            }
            

            
            if initialLoad == false{
                print("not yet decided...")
            }
            
            
        }, withCancel: nil)
        
        userReference.observeSingleEvent(of: .value) { (_) in
            initialLoad = false
        }
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let textAttributes = [NSAttributedString.Key.foregroundColor:Constants.lightColour]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.tintColor = Constants.lightColour
    }


}
