//
//  JournalHomeViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/09/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class JournalHomeViewController: UIViewController {
    
    // MARK: - Properties
    var childContentView: JournalHomeView!
    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Journal"
    }
    // MARK: - Swift UI Child View
    func addChildView() {
        childContentView = .init()
        addSwiftUIView(childContentView)
    }
}
