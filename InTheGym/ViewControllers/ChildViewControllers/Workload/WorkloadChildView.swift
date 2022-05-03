//
//  WorkloadChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class WorkloadChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.text = "Workload"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var lineChart: LineChartView = {
        let view = LineChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutSine)
        view.xAxis.axisMinimum = 0.0
        view.xAxis.axisMaximum = 7
        view.xAxis.labelPosition = XAxis.LabelPosition.bottom
        view.rightAxis.drawAxisLineEnabled = false
        view.noDataTextColor = .black
        view.noDataText = "NO DATA"
        view.xAxis.drawGridLinesEnabled = false
        view.chartDescription.enabled = false
        view.legend.enabled = false
        view.leftAxis.drawGridLinesEnabled = false
        view.leftAxis.drawAxisLineEnabled = false
        view.leftAxis.drawLabelsEnabled = false
        view.rightAxis.drawLabelsEnabled = false
        view.rightAxis.drawGridLinesEnabled = false
        view.xAxis.drawLabelsEnabled = false
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
private extension WorkloadChildView {
    func setupUI() {
        layer.cornerRadius = 8
        addViewShadow(with: .darkColour)
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(lineChart)
        addSubview(activitiyIndicator)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8),
            
            lineChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            lineChart.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            lineChart.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            lineChart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
//        addFullConstraint(to: lineChart)
        addFullConstraint(to: activitiyIndicator)
    }
}
