//
//  DefaultLoadingView.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 21/07/2024.
//

import UIKit

public protocol LoadingView: UIView {
    func showAnimated()
    func hide()
    var isVisible: Bool { get }
}

public final class DefaultLoadingUIView: UIView, LoadingView {

    public var text: String = "loading..."

    public var onHide: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    private func configure() {
        let vc = UIHostingController(rootView: DefaultLoadingView(text: text))
        let view = vc.view!
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        hide()
    }

    public var isVisible: Bool {
        return alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
        if let _ = message {
            showAnimated()
        } else {
            hideMessageAnimated()
        }
    }

    public func showAnimated() {
        

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.hide() }
            })
    }

    public func hide() {
        alpha = 0
        onHide?()
    }
}

import SwiftUI

struct DefaultLoadingView: View {
    
    var text: String = "loading..."
    
    var body: some View {
        VStack {
            Spacer()
            Text(text)
                .font(.title.weight(.semibold))
                .foregroundStyle(Color.primary)
            ProgressView()
                .tint(Color.primary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DefaultLoadingView()
}
