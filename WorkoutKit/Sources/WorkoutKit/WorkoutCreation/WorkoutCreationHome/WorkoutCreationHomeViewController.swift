//
//  WorkoutCreationHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import UIKit

class WorkoutCreationHomeViewController: UIViewController {
    
    // MARK: - Properties
    var viewModel: WorkoutCreationHomeViewModel!

    var display: WorkoutCreationHomeDisplay!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
        view.backgroundColor = .systemBackground
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "Create Workout"
        editNavBarColour(to: .darkColour)
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}
