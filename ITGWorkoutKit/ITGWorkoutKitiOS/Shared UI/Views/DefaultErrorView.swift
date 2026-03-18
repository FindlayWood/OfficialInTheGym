//
//  DefaultErrorView.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 27/07/2024.
//

import UIKit

public final class DefaultErrorUIView: UIView, LoadingView {


    public var onHide: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    

    private func configure() {
        let vc = UIHostingController(rootView: DefaultErrorView())
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

struct DefaultErrorView: View {
    
    var text: String = "Error.\nThere was an error trying to load.\nPlease try again."
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundStyle(Color.red)
            Text(text)
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.primary)
                .multilineTextAlignment(.center)
                .padding()
            Button {
                
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(Color.primary)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    DefaultErrorView()
}
