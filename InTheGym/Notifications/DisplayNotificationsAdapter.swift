//
//  DisplayNotificationsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class DisplayNotificationsAdapter:NSObject {
    
    
    var delegate : DisplayNotificationsProtocol
    
    
    init(delegate: DisplayNotificationsProtocol){
        self.delegate = delegate
    }
}
extension DisplayNotificationsAdapter: UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as! NotificationsTableViewCell
        
//        cell.notification = delegate.getData(at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No notifiications"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You will get notified when another user follows you, likes one of your post's or replies to one of your post's."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "bell_icon")
    }
    
    
}
