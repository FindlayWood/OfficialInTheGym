//
//  OptionsChildViewController.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/02/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Combine

class OptionsChildViewController: UIViewController {
    
    // MARK: - Publisher
    var optionSelected = PassthroughSubject<Options,Never>()
    
    // MARK: - Properties
    weak var coordinator: OptionsFlow?
    
    var display = OptionsChildView()
    
    var dataSource: OptionsCollectionDataSource!
    
    var options: [Options]!
    
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - View
    override func viewDidLoad() {
        super.viewDidLoad()
        initDataSource()
        initSubscriptions()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        display.frame = getFullViewableFrame()
        view.addSubview(display)
    }
    
    // MARK: - Data Source
    func initDataSource() {
        dataSource = .init(collectionView: display.collectionView)
        dataSource.updateTable(with: options)
    }
    
    // MARK: - Subscriptions
    func initSubscriptions() {
        dataSource.optionSelected
            .sink { [weak self] in self?.coordinator?.optionSelected($0)}
            .store(in: &subscriptions)
    }
}
