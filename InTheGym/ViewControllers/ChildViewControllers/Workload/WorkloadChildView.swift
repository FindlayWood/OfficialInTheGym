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
        label.textColor = .label
        label.text = "Workload"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var lineChart: BarChartView = {
        let view = BarChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutSine)
//        view.xAxis.axisMinimum = 0.0
//        view.xAxis.axisMaximum = 8
        view.leftAxis.axisMinimum = 0
        view.xAxis.labelPosition = XAxis.LabelPosition.bottom
        view.rightAxis.drawAxisLineEnabled = false
        view.noDataTextColor = .black
        view.noDataText = "NO DATA"
        view.xAxis.drawGridLinesEnabled = false
        view.chartDescription.enabled = false
        view.legend.enabled = true
        view.leftAxis.drawGridLinesEnabled = false
        view.leftAxis.drawAxisLineEnabled = true
        view.leftAxis.drawLabelsEnabled = true
        view.rightAxis.drawLabelsEnabled = false
        view.rightAxis.drawGridLinesEnabled = false
        view.xAxis.drawLabelsEnabled = true
        view.xAxis.valueFormatter = WorkloadChartXAxisFormatter(days: 7)
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.darkColour.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var segment: CustomUnderlineSegmentControl = {
        let view = CustomUnderlineSegmentControl(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width * 0.95, height: 40), buttonTitles: ["1 Week", "2 Weeks", "4 Weeks"])
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var totalWorkloadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var totalWorkloadSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Total Workload"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var acuteLoadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var acuteLoadSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Acute Load"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var chronicLoadLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var chronicLoadSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Chronic Load"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var filteredTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .semibold)
        label.textColor = .darkColour
        label.text = "0m 0s"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var filteredTimeLabelSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Total Workout Time"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Workload", for: .normal)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var allWorkloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("All Workloads", for: .normal)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var activitiyIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(segment)
        stack.addArrangedSubview(lineChart)
        stack.addArrangedSubview(totalWorkloadLabel)
        stack.addArrangedSubview(totalWorkloadSubLabel)
        stack.addArrangedSubview(acuteLoadLabel)
        stack.addArrangedSubview(acuteLoadSubLabel)
        stack.addArrangedSubview(chronicLoadLabel)
        stack.addArrangedSubview(chronicLoadSubLabel)
        stack.addArrangedSubview(filteredTimeLabel)
        stack.addArrangedSubview(filteredTimeLabelSubLabel)
        stack.addArrangedSubview(addButton)
        stack.addArrangedSubview(allWorkloadButton)
        addSubview(stack)
        addSubview(activitiyIndicator)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            segment.widthAnchor.constraint(equalTo: widthAnchor),
            segment.heightAnchor.constraint(equalToConstant: 40),
            
            lineChart.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            lineChart.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            
            allWorkloadButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            addButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            totalWorkloadLabel.heightAnchor.constraint(equalTo: filteredTimeLabel.heightAnchor),
            
            totalWorkloadLabel.heightAnchor.constraint(equalToConstant: 80),
            acuteLoadLabel.heightAnchor.constraint(equalToConstant: 80),
            chronicLoadLabel.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 30),
            
            totalWorkloadSubLabel.heightAnchor.constraint(equalToConstant: 30),
            acuteLoadSubLabel.heightAnchor.constraint(equalToConstant: 30),
            chronicLoadSubLabel.heightAnchor.constraint(equalToConstant: 30),
            filteredTimeLabelSubLabel.heightAnchor.constraint(equalToConstant: 30),
            allWorkloadButton.heightAnchor.constraint(equalToConstant: 32),
            addButton.heightAnchor.constraint(equalToConstant: 32)
        ])
        addFullConstraint(to: activitiyIndicator)
    }
}
