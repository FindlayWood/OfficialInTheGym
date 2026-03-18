//
//  ExerciseCreationHomeViewController.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import UIKit

class ExerciseCreationHomeViewController: UIViewController {

    var viewModel: ExerciseCreationHomeViewModel!
    
    var display: ExerciseCreationHomeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDisplay()
    }
    
    // MARK: - Display
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
}
