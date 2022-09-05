//
//  ExerciseMaxHistoryView.swift
//  InTheGym
//
//  Created by Findlay Wood on 30/05/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import UIKit
import Charts

class ExerciseMaxHistoryView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var lineChart: LineChartView = {
        let view = LineChartView()
        view.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInOutSine)
        view.xAxis.axisMinimum = 0.0
        view.leftAxis.axisMinimum = 0.0
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
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.darkColour.cgColor
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: generateCollectionLayout())
        view.register(ExerciseMaxHistoryCollectionCell.self, forCellWithReuseIdentifier: ExerciseMaxHistoryCollectionCell.reuseID)
        view.backgroundColor = .secondarySystemBackground
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
private extension ExerciseMaxHistoryView {
    func setupUI() {
        backgroundColor = .secondarySystemBackground
        addSubview(lineChart)
        addSubview(collectionView)
        configureUI()
    }
    
    func configureUI() {
        NSLayoutConstraint.activate([
            lineChart.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 32),
            lineChart.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            lineChart.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            lineChart.bottomAnchor.constraint(equalTo: centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    func generateCollectionLayout() -> UICollectionViewFlowLayout {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Constants.screenSize.width - 16, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        layout.scrollDirection = .vertical
        return layout
    }
}
