//
//  DisplayCircuitAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/04/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class DisplayCircuitAdapter:NSObject{
    var delegate:DisplayCircuitProtocol!
    init(delegate:DisplayCircuitProtocol) {
        self.delegate = delegate
    }
}
extension DisplayCircuitAdapter : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.retreiveNumberOfExercises()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayCircuitExerciseTableViewCell", for: indexPath) as! DisplayCircuitExerciseTableViewCell
        cell.delegate = self.delegate
        cell.setup(with: delegate.getData(at: indexPath))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "EXERCISE \(section+1)"
        label.font = .boldSystemFont(ofSize: 15)
        label.font = .preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "Menlo Bold"))
        label.backgroundColor = Constants.lightColour
        label.textAlignment = .center
        label.textColor = UIColor.white
        
        return label
    }
    
}
