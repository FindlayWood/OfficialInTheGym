//
//  PlayerMyInfoViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class PlayerMyInfoViewController: UIViewController {
    
    @IBOutlet weak var tableview:UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height

    
    var adapter : ProfileViewAdapter!
    
    lazy var viewModel: PlayerMyInfoViewModel = {
        return PlayerMyInfoViewModel()
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adapter = ProfileViewAdapter(delegate: self)
        
        tableview.delegate = adapter
        tableview.dataSource = adapter
        tableview.rowHeight = UITableView.automaticDimension
        tableview.register(UINib(nibName: "MyInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "MyInfoTableViewCell")
        
        
        initViewModel()

    }
    
    func initViewModel(){
        
        // setup for collectionview reload
        viewModel.reloadCollectionViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.tableview.reloadData()
            }
        }
        
        // Setup for updateLoadingStatusClosure
        viewModel.updateLoadingStatusClosure = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 0.0
                    })
                } else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.tableview.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.fetchData()
        
    }
    
    func moveToNewView(with index:Int){
        switch index {
        case 0:
            let Storyboard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = Storyboard.instantiateViewController(withIdentifier: "MyProfileViewController") as! MyProfileViewController
            self.navigationController?.pushViewController(SVC, animated: true)
        case 1:
            if ViewController.admin {
                let Storyboard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = Storyboard.instantiateViewController(withIdentifier: "CoachScoresViewController") as! CoachScoresViewController
                self.navigationController?.pushViewController(SVC, animated: true)
            } else {
                let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
                let SVC = StoryBoard.instantiateViewController(withIdentifier: "MYSCORESViewController") as! MYSCORESViewController
                navigationController?.pushViewController(SVC, animated: true)
            }
        case 2:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "SavedWorkoutsViewController") as! SavedWorkoutsViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 3:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "DisplayNotificationsViewController") as! DisplayNotificationsViewController
            navigationController?.pushViewController(SVC, animated: true)
        case 4:
            let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
            let SVC = StoryBoard.instantiateViewController(withIdentifier: "DisplayNotificationsViewController") as! DisplayNotificationsViewController
            navigationController?.pushViewController(SVC, animated: true)
        default:
            break
        }
    }
    
    
}

extension PlayerMyInfoViewController : ProfileViewProtocol {
    func itemSelected(at: IndexPath) {
        self.moveToNewView(with: at.section)
    }
    
    
    func getData(at: IndexPath) -> [String : AnyObject] {
        return self.viewModel.getData(at: at)
    }
    
    func retreiveNumberOfItems() -> Int {
        return 1
    }
    
    func retreiveNumberOfSections() -> Int {
        return self.viewModel.numberOfItems
    }
    
}
