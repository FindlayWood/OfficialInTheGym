//
//  DiscoverPageViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/01/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class DiscoverPageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collection:UICollectionView!
    
    let width = UIScreen.main.bounds.width
    
    var discoverPosts : [[String:Any]] = [["username":"InTheGym",
                                           "type": "workout",
                                            "title":"AB Workout",
                                            "image":UIImage(named: "benchpress_icon")!],
                                          ["username":"The Rock",
                                           "type": "user",
                                           "title":"Morning Workout",
                                           "image":UIImage(named: "benchpress_icon")!],
                                          ["username":"InTheGym",
                                           "type": "user",
                                           "title":"AB Workout",
                                           "image":UIImage(named: "benchpress_icon")!],
                                          ["username":"The Rock",
                                           "type": "workout",
                                           "title":"Morning Workout",
                                           "image":UIImage(named: "benchpress_icon")!],
                                          ["username":"InTheGym",
                                           "type": "workout",
                                            "title":"AB Workout",
                                            "image":UIImage(named: "benchpress_icon")!],
                                          ["username":"The Rock",
                                           "type": "workout",
                                            "title":"Morning Workout",
                                            "image":UIImage(named: "benchpress_icon")!]]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 5, bottom: 10, right: 5)
        layout.itemSize = CGSize(width: width/2-10, height: width/3)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        collection.collectionViewLayout = layout
        

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0{
            return 1
        }else{
            return discoverPosts.count
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
        
        
        cell.username.text = discoverPosts[indexPath.row]["username"] as? String
        cell.title.text = discoverPosts[indexPath.row]["title"] as? String
        cell.imageview.image = discoverPosts[indexPath.row]["image"] as? UIImage
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0{
            return CGSize(width: width-10, height: width/3)
        }else{
            return CGSize(width: width/2-10, height: width/3)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    

}
