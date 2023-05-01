//
//  WorkoutDisplayViewController.swift
//  
//
//  Created by Findlay-Personal on 30/04/2023.
//

import UIKit

class WorkoutDisplayViewController: UIViewController {
    
    var viewModel: WorkoutDisplayViewModel!
    
    var display: WorkoutDisplayView!

    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        view.backgroundColor = .lightColour
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.workoutModel.title
        editNavBarColour(to: .white)
    }
    
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIViewWithNavBar(display)
    }
}
