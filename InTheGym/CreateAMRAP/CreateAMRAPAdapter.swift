//
//  CreateAMRAPAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 03/06/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import Foundation
import UIKit

class CreateAMRAPAdapter: NSObject {
    
    var delegate: CreateAMRAPProtocol
    
    init(delegate: CreateAMRAPProtocol) {
        self.delegate = delegate
    }
}

extension CreateAMRAPAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.numberOfExercises()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == delegate.numberOfExercises() - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! NewExerciseCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AMRAPCell
            cell.exerciseName.text = delegate.getData(at: indexPath).exercise
            cell.repLabel.text = delegate.getData(at: indexPath).reps?.description
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            delegate.addNewExercise()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
}
