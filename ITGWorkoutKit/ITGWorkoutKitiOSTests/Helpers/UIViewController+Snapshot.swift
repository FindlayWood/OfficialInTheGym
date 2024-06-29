//
//  UIViewController+Snapshot.swift
//  ITGWorkoutKitiOSTests
//
//  Created by Findlay Wood on 10/06/2024.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection

    static func iPhone(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
        return SnapshotConfiguration(
            size: CGSize(width: 390, height: 844),
            safeAreaInsets: UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0),
            layoutMargins: UIEdgeInsets(top: 55, left: 8, bottom: 42, right: 8),
            traitCollection: UITraitCollection(mutations: { mutableTraits in
                mutableTraits.forceTouchCapability = .available
                mutableTraits.layoutDirection = .leftToRight
                mutableTraits.preferredContentSizeCategory = contentSize
                mutableTraits.userInterfaceIdiom = .phone
                mutableTraits.horizontalSizeClass = .compact
                mutableTraits.verticalSizeClass = .regular
                mutableTraits.displayScale = 3
                mutableTraits.displayGamut = .P3
                mutableTraits.userInterfaceStyle = style
            })
        )
    }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(mutations: { mutableTraits in
            mutableTraits.forceTouchCapability = configuration.traitCollection.forceTouchCapability
            mutableTraits.layoutDirection = configuration.traitCollection.layoutDirection
            mutableTraits.preferredContentSizeCategory = configuration.traitCollection.preferredContentSizeCategory
            mutableTraits.userInterfaceIdiom = configuration.traitCollection.userInterfaceIdiom
            mutableTraits.horizontalSizeClass = configuration.traitCollection.horizontalSizeClass
            mutableTraits.verticalSizeClass = configuration.traitCollection.verticalSizeClass
            mutableTraits.displayScale = configuration.traitCollection.displayScale
            mutableTraits.displayGamut = configuration.traitCollection.displayGamut
            mutableTraits.userInterfaceStyle = configuration.traitCollection.userInterfaceStyle
        })
    }
    
    
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { action in
            layer.render(in: action.cgContext)
        }
    }
}
