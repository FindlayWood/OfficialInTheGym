//
//  ExerciseCommentsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 04/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit

class ExerciseCommentsViewController: UIViewController {
    // MARK: - Properties
    var display = ExerciseCommentsView()
    var viewModel = ExerciseCommentsViewModel()
    // MARK: - View
    override func loadView() {
        view = display
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
