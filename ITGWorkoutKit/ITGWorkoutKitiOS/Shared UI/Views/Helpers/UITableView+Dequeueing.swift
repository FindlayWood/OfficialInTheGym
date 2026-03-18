//
//  UITableView+Dequeueing.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 27/04/2024.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
