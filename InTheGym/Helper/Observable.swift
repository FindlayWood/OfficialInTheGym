//
//  Observable.swift
//  InTheGym
//
//  Created by Findlay-Personal on 21/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import Foundation

class Observable<T: Codable> {
    var value : T? {
        didSet {
            if let value = value{
                DispatchQueue.main.async {
                    self.valueChanged?(value)
                }
            }
        }
    }
    var valueChanged: ((T) -> Void)?
}
