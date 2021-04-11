//
//  DiscoverPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class DiscoverPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection:UICollectionView!
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
    
    var discoverPosts = [DiscoverPosts]()
    var initialPostRef : [String] = []
    var posts : [[String:AnyObject]] = []
    var WOD : [String:AnyObject] = [:]
    
    var activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    var selfUsername:String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: width/2-10, height: width/3)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collection.collectionViewLayout = layout
        
        loadPosts()
        view.addSubview(activityIndicator)
        activityIndicator.frame = self.view.frame
        activityIndicator.startAnimating()
        activityIndicator.color = Constants.darkColour
        self.collection.alpha = 0.0

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else{
            return posts.count
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoverPageCollectionViewCell
        cell.layer.cornerRadius = 8
        
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 3.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        
        if indexPath.section == 0{
            cell.username.text = WOD["createdBy"] as? String ?? ""
            cell.title.text = WOD["title"] as? String ?? ""
            cell.exerciseCount.text = "\(WOD["exercises"]?.count ?? 0) exercises"
            cell.downloadCount.text = WOD["NumberOfDownloads"]?.description
            cell.viewCount.text = WOD["Views"]?.description
            cell.crownImage.isHidden = false
            cell.wodMessage.isHidden = false
            
        }
        
        else{
            cell.username.text = posts[indexPath.item]["createdBy"] as? String
            cell.title.text = posts[indexPath.item]["title"] as? String
            cell.exerciseCount.text = posts[indexPath.item]["exercises"]?.count?.description
            cell.downloadCount.text = posts[indexPath.item]["NumberOfDownloads"]?.description
            cell.viewCount.text = posts[indexPath.item]["Views"]?.description
            cell.crownImage.isHidden = true
            cell.wodMessage.isHidden = true
        }
        
        cell.imageview.image = UIImage(named: "benchpress_icon")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let workoutOutDetail = storyboard.instantiateViewController(withIdentifier: "WorkoutDetailViewController") as! WorkoutDetailViewController
        workoutOutDetail.playerID = Auth.auth().currentUser!.uid
        workoutOutDetail.username = selfUsername
        workoutOutDetail.fromDiscover = true
        
        if indexPath.section == 0{
            WorkoutDetailViewController.exercises = self.WOD["exercises"] as! [[String:AnyObject]]
            workoutOutDetail.titleString = WOD["title"] as! String
            workoutOutDetail.creatorID = WOD["creatorID"] as! String
            workoutOutDetail.creatorUsername = WOD["createdBy"] as! String
            workoutOutDetail.workoutID = WOD["workoutID"] as! String
        }else{
            WorkoutDetailViewController.exercises = self.posts[indexPath.item]["exercises"] as! [[String : AnyObject]]
            workoutOutDetail.titleString = posts[indexPath.item]["title"] as! String
            workoutOutDetail.creatorID = posts[indexPath.item]["creatorID"] as! String
            workoutOutDetail.creatorUsername = posts[indexPath.item]["createdBy"] as! String
            workoutOutDetail.workoutID = posts[indexPath.item]["workoutID"] as! String
        }
        
        self.navigationController?.pushViewController(workoutOutDetail, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0{
            return CGSize(width: width-10, height: height/5)
        }else{
            return CGSize(width: width/2-10, height: width/2.5)
        }
    }
    
    
    func loadPosts(){
        let discoverRef = Database.database().reference().child("Discover").child("WOD")
        let savedWorkoutRef = Database.database().reference().child("SavedWorkouts")
        
        
        discoverRef.observeSingleEvent(of: .childAdded) { (snapshot) in
            let wodID = snapshot.key
            savedWorkoutRef.child(wodID).observeSingleEvent(of: .value) { (snapshot) in
                if var snap = snapshot.value as? [String:AnyObject]{
                    snap["workoutID"] = wodID as AnyObject
                    self.WOD = snap
                }
            }
        }
        
        
        let discoverWorkoutsRef = Database.database().reference().child("Discover").child("Workouts")
        discoverWorkoutsRef.observe(.childAdded) { (snapshot) in
            self.initialPostRef.insert(snapshot.key, at: 0)
            
        }
        discoverWorkoutsRef.observeSingleEvent(of: .value) { (_) in
            self.loadDiscoverWorkouts()
        }
    }
    
    func observePosts(){
        // in here will need to be observers to catch updates
        // but will not change unless pull to refresh
        
    }
    
    func loadDiscoverWorkouts(){
        
        let savedWorkoutRef = Database.database().reference().child("SavedWorkouts")
        
        let myGroup = DispatchGroup()
        
        for post in initialPostRef{
            myGroup.enter()
            savedWorkoutRef.child(post).observeSingleEvent(of: .value) { (snapshot) in
                defer {myGroup.leave()}
                
                guard var snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                snap["workoutID"] = post as AnyObject
                self.posts.insert(snap, at: 0)
                
                
            }
            myGroup.notify(queue: .main){
                self.collection.reloadData()
                self.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2) {
                    self.collection.alpha = 1.0
                }
                self.activityIndicator.isHidden = true
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        selfUsername = ViewController.username
    }
    
    

}
