//
//  OptimalWorkloadRatioView.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class OptimalWorkloadRatioView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 50, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 2
        label.text = "Acute Chronic Workload Ratio \n ACWR"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 60, weight: .semibold)
        label.textColor = .darkColour
        label.text = "Optimal"
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var statusSubLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .secondaryLabel
        label.text = "Current Status"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var horizontalBar: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: Constants.screenSize.width * 0.8, height: 16))
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var centerCircleView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightColour
        view.layer.cornerRadius = 50
        view.addViewShadow(with: .darkColour)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var centerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.text = "1.3"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var underLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Under \n Training"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var optimalLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = "Optimal"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var overLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Over \n Training"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var acwrLineChart: LineChartView = {
        let view = LineChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInCubic)
//        view.xAxis.axisMinimum = 0
//        view.xAxis.axisMaximum = 7
        view.leftAxis.axisMaximum = 2
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
        view.xAxis.valueFormatter = ACWRChartXAxisFormatter()
//        view.xAxis.labelCount = 4
        view.leftAxis.labelCount = 4
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.darkColour.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var topLimitLine: ChartLimitLine = {
        let view = ChartLimitLine(limit: 1.5, label: "Over Training")
        view.lineColor = .red
        return view
    }()
    var bottomLimitLine: ChartLimitLine = {
        let view = ChartLimitLine(limit: 0.8, label: "Under Training")
        view.lineColor = .lightColour
        return view
    }()
    var topPerformanceLine: ChartLimitLine = {
        let view = ChartLimitLine(limit: 1.3, label: "Peak Performance")
        view.lineColor = .green
        return view
    }()
    var moreACWRButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("more ACWR", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var monotonyLineChart: LineChartView = {
        let view = LineChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInCubic)
        view.leftAxis.axisMaximum = 3
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
        view.xAxis.valueFormatter = ACWRChartXAxisFormatter()
        view.leftAxis.labelCount = 3
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.darkColour.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var moreMonotonyButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("more Monotony", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var monotonyLimitLine: ChartLimitLine = {
        let view = ChartLimitLine(limit: 2, label: "Too High")
        view.lineColor = .red
        return view
    }()
    var trainingStrainLineChart: LineChartView = {
        let view = LineChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInCubic)
//        view.leftAxis.axisMaximum = 3
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
        view.xAxis.valueFormatter = ACWRChartXAxisFormatter()
        view.leftAxis.labelCount = 3
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.darkColour.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var moreTrainingStrainButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .darkColour
        button.setTitle("more Training Strain", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
private extension OptimalWorkloadRatioView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 2
        layer.borderColor = UIColor.darkColour.cgColor
        addSubview(titleLabel)
        addSubview(statusLabel)
        addSubview(statusSubLabel)
        addSubview(horizontalBar)
        addSubview(underLabel)
        addSubview(optimalLabel)
        addSubview(overLabel)
        addSubview(acwrLineChart)
        acwrLineChart.leftAxis.addLimitLine(topLimitLine)
        acwrLineChart.leftAxis.addLimitLine(bottomLimitLine)
        acwrLineChart.leftAxis.addLimitLine(topPerformanceLine)
        addSubview(moreACWRButton)
        addSubview(monotonyLineChart)
        addSubview(moreMonotonyButton)
        monotonyLineChart.leftAxis.addLimitLine(monotonyLimitLine)
        addSubview(trainingStrainLineChart)
        addSubview(moreTrainingStrainButton)
        configureUI()
        addGradient()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            
            statusSubLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            statusSubLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            horizontalBar.topAnchor.constraint(equalTo: statusSubLabel.bottomAnchor, constant: 80),
            horizontalBar.centerXAnchor.constraint(equalTo: centerXAnchor),
            horizontalBar.heightAnchor.constraint(equalToConstant: 16),
            horizontalBar.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            centerCircleView.heightAnchor.constraint(equalToConstant: 100),
            centerCircleView.widthAnchor.constraint(equalToConstant: 100),
            
            underLabel.topAnchor.constraint(equalTo: horizontalBar.bottomAnchor, constant: 60),
            underLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            
            optimalLabel.topAnchor.constraint(equalTo: horizontalBar.bottomAnchor, constant: 60),
            optimalLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            overLabel.topAnchor.constraint(equalTo: horizontalBar.bottomAnchor, constant: 60),
            overLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
//            overLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            acwrLineChart.topAnchor.constraint(equalTo: overLabel.bottomAnchor, constant: 16),
            acwrLineChart.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            acwrLineChart.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            acwrLineChart.centerXAnchor.constraint(equalTo: centerXAnchor),
//            acwrLineChart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            moreACWRButton.topAnchor.constraint(equalTo: acwrLineChart.bottomAnchor, constant: 8),
            moreACWRButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreACWRButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
//            moreACWRButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            monotonyLineChart.topAnchor.constraint(equalTo: moreACWRButton.bottomAnchor, constant: 16),
            monotonyLineChart.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            monotonyLineChart.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            monotonyLineChart.centerXAnchor.constraint(equalTo: centerXAnchor),
//            monotonyLineChart.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            moreMonotonyButton.topAnchor.constraint(equalTo: monotonyLineChart.bottomAnchor, constant: 8),
            moreMonotonyButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreMonotonyButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            trainingStrainLineChart.topAnchor.constraint(equalTo: moreMonotonyButton.bottomAnchor, constant: 16),
            trainingStrainLineChart.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            trainingStrainLineChart.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            trainingStrainLineChart.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            moreTrainingStrainButton.topAnchor.constraint(equalTo: trainingStrainLineChart.bottomAnchor, constant: 8),
            moreTrainingStrainButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            moreTrainingStrainButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            moreTrainingStrainButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    func addGradient() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame.size = horizontalBar.frame.size
        gradient.colors = [UIColor.white.cgColor,UIColor.white.cgColor,UIColor.lightColour.cgColor,UIColor.lightColour.cgColor,UIColor.darkColour.cgColor,UIColor.darkColour.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        horizontalBar.layer.addSublayer(gradient)
    }
}
// MARK: - Public Configuration
extension OptimalWorkloadRatioView {
    public func setRatio(to ratio: Double) {
        var ratio = ratio
        if ratio > 2 {
            ratio = 2
        }
        addSubview(centerCircleView)
        centerCircleView.addSubview(centerLabel)
        centerLabel.text = ratio.rounded(toPlaces: 1).description
        NSLayoutConstraint.activate([
            centerCircleView.centerYAnchor.constraint(equalTo: horizontalBar.centerYAnchor),
            centerLabel.centerXAnchor.constraint(equalTo: centerCircleView.centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: centerCircleView.centerYAnchor),
            centerLabel.widthAnchor.constraint(equalTo: centerCircleView.widthAnchor),
            centerLabel.heightAnchor.constraint(equalTo: centerCircleView.heightAnchor)
        ])
        let offset: CGFloat = (ratio * (0.5 * horizontalBar.frame.width)) - (0.5 * horizontalBar.frame.width)
        NSLayoutConstraint.activate([
            centerCircleView.centerXAnchor.constraint(equalTo: horizontalBar.centerXAnchor, constant: offset),
        ])
        if ratio >= 0.8 && ratio < 1.5 {
            statusLabel.text = "Optimal"
            centerCircleView.backgroundColor = .lightColour
        } else if ratio < 0.8 {
            statusLabel.text = "Under Training"
            centerCircleView.backgroundColor = .lightColour.withAlphaComponent(0.6)
            centerCircleView.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
        } else if ratio >= 1.5 {
            statusLabel.text = "Over Training"
            centerCircleView.backgroundColor = .darkColour
        }
    }
}
