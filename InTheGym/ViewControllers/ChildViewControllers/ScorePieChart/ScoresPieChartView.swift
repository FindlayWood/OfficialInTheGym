//
//  ScoresPieChartView.swift
//  InTheGym
//
//  Created by Findlay Wood on 05/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class ScoresPieChartView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var pieChartView: PieChartView = {
        let view = PieChartView()
        view.legend.enabled = false
        view.drawEntryLabelsEnabled = false
        view.holeColor = .lightColour
//        view.addViewShadow(with: .darkColour)
        view.layer.cornerRadius = 8
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var activitiyIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
}
// MARK: - Configure
private extension ScoresPieChartView {
    func setupUI() {
        layer.cornerRadius = 8
        addViewShadow(with: .darkColour)
        backgroundColor = .lightColour
        addSubview(pieChartView)
        addSubview(activitiyIndicator)
        configureUI()
    }
    
    func configureUI() {
//        pieChartView.frame = frame
        addFullConstraint(to: pieChartView)
        addFullConstraint(to: activitiyIndicator)
        
    }
}
