//
//  BaseControllerViewController.swift
//  InTheGym
//
//  Created by Findlay-Personal on 09/06/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit

class BaseControllerViewController: UIViewController {
    
    var coordinator: BaseControllerCoordinator?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle("Test Button", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    @objc func buttonAction(sender: UIButton!) {
    }
}
