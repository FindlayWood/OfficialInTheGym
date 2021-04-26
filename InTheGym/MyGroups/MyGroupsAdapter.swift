//
//  MyGroupsAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit
import EmptyDataSet_Swift

class MyGroupsAdapter : NSObject {
    
    var delegate:MyGroupsProtocol!
    init(delegate:MyGroupsProtocol){
        self.delegate = delegate
    }
}

extension MyGroupsAdapter : UITableViewDelegate, UITableViewDataSource, EmptyDataSetSource, EmptyDataSetDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfGroups()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupTableViewCell", for: indexPath) as! MyGroupTableViewCell
        let group = delegate.getGroup(at: indexPath)
        cell.setup(with: group)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.groupSelected(at: indexPath)
    }
    
    // emptydataset functions
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Groups"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "You are not part of any groups yet. Groups are a great way to share workouts with who you want and monitor a specific group of users."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "groups_icon")
    }
    
}
