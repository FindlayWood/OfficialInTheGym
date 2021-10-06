//
//  CreateEMOMAdapter.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class CreateEMOMAdapter: NSObject {
    
    var delegate: CreateEMOMProtocol
    
    init(delegate: CreateEMOMProtocol) {
        self.delegate = delegate
    }
}

extension CreateEMOMAdapter: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate.numberOfExercises()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == delegate.numberOfExercises() - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NewExerciseCell.cellID, for: indexPath) as! NewExerciseCell
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AMRAPCell.cellID, for: indexPath) as! AMRAPCell
            cell.exerciseName.text = delegate.getData(at: indexPath).exercise
            cell.repLabel.text = delegate.getData(at: indexPath).reps?.description
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == delegate.numberOfExercises() - 1 {
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
