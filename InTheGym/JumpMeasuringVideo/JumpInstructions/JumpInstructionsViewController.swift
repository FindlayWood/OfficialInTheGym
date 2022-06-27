//
//  JumpInstructionsViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import SwiftUI

class JumpInstructionsViewController: UIViewController {
    // MARK: - Properties
    var childContentView: JumpInstructionsView!
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addChildView()
    }
    // MARK: - Add Child SwiftUI view
    func addChildView() {
        childContentView = JumpInstructionsView(instructions: instructions)
        let viewController = UIHostingController(rootView: childContentView)
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            viewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            viewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    var instructions: [JumpInstruction] = [.init(number: 1, instruction: "Find some space gor you to record your jump. Enough space around so you wont bash off anything and around 2m away from the camera."),
                                           .init(number: 2, instruction: "When recording starts you have 16 seconds to jump and land. It is important that both your take off and landing are captured on the recording."),
                                           .init(number: 3, instruction: "Once you have recorded your jump you will then be shown the tagging screen. Here you must tag your take off and landing."),
                                           .init(number: 4, instruction: "To tag your take off, select last frame with your feet touching the ground before you jump. (you can't select the very first frame of the video)"),
                                           .init(number: 5, instruction: "To tag your landing, select first frame with your feet touching the ground after you jump."),
                                           .init(number: 6, instruction: "Once you have tagged your jump (take off must come before landing) then you will see a right arrow button in the top right. Tap this to see your results.")]
}
