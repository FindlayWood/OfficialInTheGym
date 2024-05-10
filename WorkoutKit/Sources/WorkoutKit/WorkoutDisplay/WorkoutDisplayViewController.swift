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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = viewModel.workoutModel.title
        editNavBarColour(to: .white)
    }
    
    func addDisplay() {
        display = .init(viewModel: viewModel)
        addSwiftUIView(display)
    }
    
    func showMyViewControllerInACustomizedSheet() {
        let viewControllerToPresent = BViewController()
        if let sheet = viewControllerToPresent.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        present(viewControllerToPresent, animated: true, completion: nil)
    }
}


class BViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}
