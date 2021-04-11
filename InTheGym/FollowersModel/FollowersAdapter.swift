//
//  FollowersAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/03/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit


class FollowersAdapter:NSObject{
    
    
    var delegate : FollowersDisplayProtocol
    
    
    init(delegate: FollowersDisplayProtocol){
        self.delegate = delegate
    }
}
extension FollowersAdapter: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate.retreiveNumberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowersDisplayTableViewCell", for: indexPath) as! FollowersDisplayTableViewCell
        
        cell.user = delegate.getData(at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.itemSelected(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    
    
    
}
