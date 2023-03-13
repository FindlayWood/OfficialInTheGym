//
//  SavedWorkoutBottomChildView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/03/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SavedWorkoutOptionsBottomSheetView: View {
    
    @ObservedObject var viewModel: SavedWorkoutBottomChildViewModel
    
    var action: (Options) -> ()
    
    var body: some View {
        ZStack {
            List {
                Section {
                    ForEach(viewModel.optionsList, id: \.self) { option in
                        Button {
                            action(option)
                        } label: {
                            HStack {
                                Image(systemName: option.imageName)
                                    .foregroundColor(Color(.darkColour))
                                Text(option.rawValue)
                                    .font(.headline)
                                    .foregroundColor(Color(.darkColour))
                            }
                        }
                    }
                } header: {
                    Text("Workout Options")
                }
                if viewModel.isWorkoutSaved {
                    Section {
                        Button {
                            action(.delete)
                        } label: {
                            HStack {
                                Image(systemName: Options.delete.imageName)
                                    .foregroundColor(.red)
                                Text(Options.delete.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        }
                    } header: {
                        Text("Delete")
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.optionsList)
            
            if viewModel.isLoading {
                LoadingView()
            }
            if viewModel.isShowingSuccess {
                SuccessView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.viewModel.isShowingSuccess = false
                        }
                    }
            }
        }
    }
}


import Foundation
import UIKit

class SavedWorkoutBottomChildView: UIView {
    // MARK: - Properties
    
    // MARK: - Subviews
    var scrollIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.heightAnchor.constraint(equalToConstant: 6).isActive = true
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var optionsButton: UIButton = {
        let label = UIButton()
        label.titleLabel?.font = UIFont(name: "Menlo-Bold", size: 25)
        label.setTitleColor(.darkColour, for: .normal)
        label.setTitle("OPTIONS", for: .normal)
        label.contentHorizontalAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
private extension SavedWorkoutBottomChildView {
    func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        addViewTopShadow(with: .black)
        addSubview(scrollIndicatorView)
        addSubview(optionsButton)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            scrollIndicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            scrollIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            scrollIndicatorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            
            optionsButton.topAnchor.constraint(equalTo: scrollIndicatorView.bottomAnchor, constant: 8),
            optionsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            optionsButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
            
        ])
    }
}
