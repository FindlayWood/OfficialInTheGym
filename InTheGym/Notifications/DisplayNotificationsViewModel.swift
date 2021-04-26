//
//  DisplayNotificationsViewModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import Firebase

class DisplayNotificationsViewModel {
    
    
    // MARK: - Closures
        
    // Through these closures, our view model will execute code while some events will occure
    // They will be set up by the view controller
    
    var reloadTableViewClosure: (() -> ())?
    var updateLoadingStatusClosure: (() -> ())?
    
    // MARK: - Properties
    
    // We defined the FakeAPIServiceProtocol in the FakeAPIService.swift file.
    // We also defined a class and make it conform to that protocol.
    var apiService: DatabaseReference
    let userID = Auth.auth().currentUser!.uid
    var notificationsReference : DatabaseReference!
    var handle : DatabaseHandle!

    // This will contain info about the picture eventually selectded by the user by tapping an item on the screen
    var selectedNotifications: NotificationTableViewModel?
    
    // The collection that will contain our fetched data
    private var notifications: [NotificationTableViewModel] = [] {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    // A property containing the number ot items, it will be used by the view controller to render items on the screen using a
    var numberOfItems: Int {
        return notifications.count
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatusClosure?()
        }
    }
    
    // MARK: - Constructor
    
    // Note: apiService has a default value in case this constructor is executed without passing parameters
    init(apiService: DatabaseReference) {
        self.apiService = apiService
        self.notificationsReference = Database.database().reference().child("Notifications").child(self.userID)
    }
 
    
    // MARK: - Fetching functions
    func fetchData(){
        self.isLoading = true
        
        var tempNotifs = [NotificationTableViewModel]()
        let myGroup = DispatchGroup()
        
        handle = notificationsReference.observe(.childAdded) { (snapshot) in
                        
            if snapshot.childrenCount == 0 {
                self.notifications = []
                self.isLoading = false
            } else {
                myGroup.enter()
                guard let snap = snapshot.value as? [String:AnyObject] else{
                    return
                }
                let tempModel = NotificationTableViewModel(snapshot: snapshot)
                UserIDToUser.transform(userID: snap["fromUserID"] as! String) { (user) in
                    tempModel!.from = user
                    tempNotifs.insert(tempModel!, at: 0)
                    myGroup.leave()
                }
                myGroup.notify(queue: .main){
                    tempNotifs.sort(by: {$0.time! > $1.time!})
                    self.notifications = tempNotifs
                    self.isLoading = false
                }
            }
        }
        notificationsReference.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.childrenCount == 0 {
                self.isLoading = false
            }
        }
    }
    
    //MARK: - Remove Observers
    func removeObservers(){
        notificationsReference.removeObserver(withHandle: handle)
    }
    
    
    
    // MARK: - Retieve Data
    
    func getData( at indexPath: IndexPath ) -> NotificationTableViewModel {
        return notifications[indexPath.row]
    }
    
    
    
    
    
    
    
    
}
