//
//  TimeSelectionViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/09/2021.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

class TimeSelectionViewController: UIViewController {
    
    weak var coordinator: TimeSelectionPickerCoordinator?
    
    // the display configured outside vc
    var display = TimeSelectionViewControllerView()
    
    // tableview adapter
    var adapter: TimeSelectionAdapter!
    
    // parent delegate callback
    weak var parentDelegate: TimeSelectionParentDelegate!

    var currentSelectedTime: Int = 10 {
        didSet {
            display.tableview.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        initAdapter()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    func initAdapter() {
        adapter = .init(delegate: self)
        display.tableview.delegate = adapter
        display.tableview.dataSource = adapter
        display.tableview.backgroundColor = .offWhiteColour
    }
}

extension TimeSelectionViewController: TimeSelectionProtocol {
    func getCurrentTime() -> Int {
        return currentSelectedTime
    }
    func newTimeSelected(_ time: Int) {
        currentSelectedTime = time
        parentDelegate.timeSelected(newTime: time)
        //coordinator?.dismissPicker()
        self.dismiss(animated: true)
    }
}
