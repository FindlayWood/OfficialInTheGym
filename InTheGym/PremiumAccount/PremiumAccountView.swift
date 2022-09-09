//
//  PremiumAccountView.swift
//  InTheGym
//
//  Created by Findlay Wood on 15/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//
import SwiftUI
import RevenueCat

struct PremiumAccountViewSwiftUI: View {
    @StateObject var viewModel = PremiumAccountViewModel()
    var body: some View {
        VStack {
            Text("Premium Account")
                .font(.largeTitle.bold())
                .foregroundColor(Color(.darkColour))
            Text("Sign up for a premium account and gain access to awesome features and power yourself into an elite athlete.")
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)
            HStack {
                Image("clip_icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("Clips")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Record and upload clips.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                Image("monitor_icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                VStack(alignment: .leading) {
                    Text("Performance Center")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Gain access to the performance center.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            HStack {
                ForEach(viewModel.subscriptionPackages) { package in
                    VStack {
                        Text(package.storeProduct.subscriptionPeriod?.durationTitle ?? "Error")
                        Text(package.storeProduct.localizedPriceString)
                        if viewModel.selectedPackage == package {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(.darkColour))
                        } else {
                            Button {
                                viewModel.selectedPackage = package
                            } label: {
                                Image(systemName: "cicrle")
                                    .foregroundColor(Color(.darkColour))
                            }
                        }
                    }
                }
            }
            Button {
                
            } label: {
                Text("Subscribe")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkColour))
                    .padding()
            }
            Text("Recurring bill, cancel anytime, \n Your payment will be charged to your iTunes account and your subscription will automatically renew for the same package length at the same price until you cancel it. Cancel anytime from settings -> subscriptions.")
                .font(.footnote)
                .foregroundColor(Color(.tertiaryLabel))
        }
        .task {
            await viewModel.fetchIAPOfferings()
        }
    }
}

import UIKit

class PremiumAccountView: UIView {
    // MARK: - Subviews
    var topLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .bold)
        label.textColor = .darkColour
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.lineBreakMode = .byClipping
        label.text = "Premium Account"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.textColor = .secondaryLabel
        label.text = "Sign up for a premium account and gain access to awesome features and power yourself into an elite athlete."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    var monthlyView: MonthlySubscriptionView = {
        let view = MonthlySubscriptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var yearlyView: YearlySubscriptionView = {
        let view = YearlySubscriptionView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var clipSubscriptionView: ClipSubscriptionView = {
        let view = ClipSubscriptionView()
        view.configure(with: UIImage(named: "clip_icon"), title: "Clips", message: "Record and upload clips.")
        return view
    }()
    var performanceSubview: ClipSubscriptionView = {
        let view = ClipSubscriptionView()
        view.configure(with: UIImage(named: "monitor_icon"), title: "Performance Monitor", message: "Gain access to the performance monitor.")
        return view
    }()
    lazy var subscriptionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [monthlyView, yearlyView])
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        return stack
    }()
    var subscribeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Subscribe", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.backgroundColor = .darkColour
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    var billingMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.text = "Recurring bill, cancel anytime, \n Your payment will be charged to your iTunes account and your subscription will automatically renew for the same package length at the same price until you cancel it. Cancel anytime from settings -> subscriptions."
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [topLabel,messageLabel,clipSubscriptionView,performanceSubview,subscriptionsStack,subscribeButton,billingMessageLabel])
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
private extension PremiumAccountView {
    func setupUI() {
        backgroundColor = .systemBackground
        addSubview(stack)
        configureUI()
    }
    func configureUI() {
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
            
            topLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            subscribeButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            monthlyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            yearlyView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4),
            clipSubscriptionView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            performanceSubview.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            billingMessageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
        ])
    }
}
// MARK: - Public Config
extension PremiumAccountView {
    public func setSelection(to type: SubscriptionEnum) {
        switch type {
        case .monthly:
            monthlyView.setSelection(to: true)
            yearlyView.setSelection(to: false)
        case .yearly:
            yearlyView.setSelection(to: true)
            monthlyView.setSelection(to: false)
        }
    }
}
