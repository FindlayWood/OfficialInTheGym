//
//  MyDayHomeViewController.swift
//  MyDayKit
//
//  Created by Findlay Wood on 20/11/2025.
//

import UIKit

public class MyDayHomeViewController: UIViewController {

    // MARK: - Managers & Callbacks
    var dayManager: MyDayManager!

    var addButtonAction: (() -> Void)?
    var addSpecificExercise: ((MyDayNewExerciseManager) -> Void)?
    var recordClip: (() -> Void)?

    // MARK: - UI
    private let topTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "MYDAY"
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.tintColor = .black
        button.widthAnchor.constraint(equalToConstant: 28).isActive = true
        button.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return button
    }()
    
    private let dateSelectorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor.systemGray6
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()
    
    private var dateDropDownVisible = false {
        didSet { updateDateDropdown() }
    }
    
    private lazy var dateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 12
        layout.minimumLineSpacing = 12
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(DateCell.self, forCellWithReuseIdentifier: "DateCell")
        cv.showsHorizontalScrollIndicator = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let exercisesTableView: UITableView = {
        let tv = UITableView()
        tv.register(ExerciseCell.self, forCellReuseIdentifier: "ExerciseCell")
        tv.separatorStyle = .none
        return tv
    }()
    
    // MARK: - Date List
    private let calendar = Calendar.current
    private lazy var dates: [Date] = {
        let today = calendar.startOfDay(for: Date())
        return (-3..<30).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }()
    
    private let dfShort: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E\nd"
        return f
    }()
    
    private let dfHeader: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E - d"
        return f
    }()
    
    // MARK: - Public Initializer
    public init(dayManager: MyDayManager) {
        self.dayManager = dayManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("MyDayHomeViewController must be created using init(dayManager:)")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        dateCollectionView.delegate = self
        dateCollectionView.dataSource = self
        
        exercisesTableView.delegate = self
        exercisesTableView.dataSource = self
        
        setupLayout()
        setupActions()
        refreshDateHeader()
    }

    // MARK: - Setup
    private func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        dateSelectorButton.addTarget(self, action: #selector(toggleDateDropdown), for: .touchUpInside)
    }
    
    private func setupLayout() {
        let topBar = UIStackView(arrangedSubviews: [topTitleLabel, UIView(), addButton])
        topBar.axis = .horizontal
        topBar.alignment = .center
        
        view.addSubview(topBar)
        view.addSubview(dateSelectorButton)
        view.addSubview(dateCollectionView)
        view.addSubview(exercisesTableView)
        
        topBar.translatesAutoresizingMaskIntoConstraints = false
        dateSelectorButton.translatesAutoresizingMaskIntoConstraints = false
        dateCollectionView.translatesAutoresizingMaskIntoConstraints = false
        exercisesTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateSelectorButton.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 8),
            dateSelectorButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateSelectorButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateSelectorButton.heightAnchor.constraint(equalToConstant: 38),
            
            dateCollectionView.topAnchor.constraint(equalTo: dateSelectorButton.bottomAnchor, constant: 8),
            dateCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dateCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dateCollectionView.heightAnchor.constraint(equalToConstant: 70),
            
            exercisesTableView.topAnchor.constraint(equalTo: dateCollectionView.bottomAnchor),
            exercisesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            exercisesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            exercisesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        dateCollectionView.isHidden = true
    }
    
    // MARK: - Actions
    @objc private func addButtonTapped() {
        addButtonAction?()
    }
    
    @objc private func toggleDateDropdown() {
        dateDropDownVisible.toggle()
    }
    
    private func updateDateDropdown() {
        UIView.animate(withDuration: 0.25) {
            self.dateCollectionView.isHidden = !self.dateDropDownVisible
        }
    }
    
    private func refreshDateHeader() {
        guard let selectedDay = dayManager.selectedDay else { return }
        
        if calendar.isDateInToday(selectedDay.date) {
            dateSelectorButton.setTitle("Today", for: .normal)
        } else {
            dateSelectorButton.setTitle(dfHeader.string(from: selectedDay.date), for: .normal)
        }
        
        addButton.isEnabled = dayManager.isTodaySelected()
        addButton.alpha = dayManager.isTodaySelected() ? 1.0 : 0.3
        
        exercisesTableView.reloadData()
    }
}

extension MyDayHomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateCell", for: indexPath) as! DateCell
        
        let date = dates[indexPath.item]
        let isSelected = dayManager.isDaySelected(date)
        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()
        
        cell.configure(
            date: date,
            isSelected: isSelected,
            isFuture: isFuture,
            formatter: dfShort
        )
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = dates[indexPath.item]
        
        guard date <= Date() else { return }
        
        dayManager.changeSelectedDay(to: date)
        refreshDateHeader()
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 60)
    }
}

extension MyDayHomeViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dayManager.selectedDay?.exercises.count ?? 0
    }

    public func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ExerciseCell",
            for: indexPath
        ) as! ExerciseCell
        
        guard let exercise = dayManager.selectedDay?.exercises[indexPath.row] else { return cell }

        cell.configure(with: exercise)
        
        cell.addAction = { [weak self] in
            let newModel = MyDayNewExerciseManager(exercise: exercise.exercise)
            self?.addSpecificExercise?(newModel)
        }

        cell.clipAction = { [weak self] in
            self?.recordClip?()
        }

        return cell
    }
}


class DateCell: UICollectionViewCell {

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor.systemGray6
        
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    func configure(date: Date, isSelected: Bool, isFuture: Bool, formatter: DateFormatter) {
        label.text = formatter.string(from: date)
        
        contentView.backgroundColor = isSelected ? .systemBlue : UIColor.systemGray6
        label.textColor = isSelected ? .white : .black
        
        contentView.alpha = isFuture ? 0.3 : 1.0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ExerciseCell: UITableViewCell {

    let titleLabel = UILabel()
    let addButton = UIButton(type: .system)
    let clipButton = UIButton(type: .system)

    var addAction: (() -> Void)?
    var clipAction: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = .boldSystemFont(ofSize: 16)
        
        addButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        clipButton.setImage(UIImage(systemName: "video.circle"), for: .normal)

        let stack = UIStackView(arrangedSubviews: [titleLabel, UIView(), clipButton, addButton])
        stack.axis = .horizontal
        stack.spacing = 12
        
        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        clipButton.addTarget(self, action: #selector(clipTapped), for: .touchUpInside)
    }

    func configure(with exercise: MyDayExerciseModel) {
        titleLabel.text = exercise.exercise.name
    }
    
    @objc private func addTapped() { addAction?() }
    @objc private func clipTapped() { clipAction?() }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


