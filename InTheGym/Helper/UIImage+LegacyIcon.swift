//
//  UIImage+LegacyIcon.swift
//  InTheGym
//
//  Created by Findlay Wood on 18/10/2026.
//  Copyright © 2021 FindlayWood. All rights reserved.
//

import UIKit

extension UIImage {
    /// An SF Symbol drawn the way the icons8 PNGs it replaced were: a square bitmap with the glyph
    /// centred and in colour. The legacy screens put those PNGs into square frames with
    /// `scaleToFill`, `.resizable()` and plain `UIButton`s, so **a bare `UIImage(systemName:)`
    /// dropped in their place would stretch wide glyphs and pick up the system-blue tint** at every
    /// call site. Rendering into a square, in a fixed colour, keeps all ~140 call sites unchanged.
    /// The light and dark renders are registered in one `UIImageAsset`, so a `UIImageView` still
    /// switches with the appearance. New screens use SF Symbols directly, never this.
    static func legacyIcon(_ systemName: String, colour: UIColor = .adaptiveDarkColour) -> UIImage {
        let asset = UIImageAsset()
        for style in [UIUserInterfaceStyle.light, .dark] {
            let traits = UITraitCollection(userInterfaceStyle: style)
            asset.register(renderSquare(systemName, colour: colour.resolvedColor(with: traits), traits: traits), with: traits)
        }
        return asset.image(with: UITraitCollection.current)
    }

    /// The icon for a legacy RTDB activity, whose `type` string ("Following", "New Group", …) was
    /// also the name of the asset drawn beside it. The icons8 ones are mapped here; any other type
    /// still resolves to an asset of that name.
    static func legacyActivityIcon(for type: String) -> UIImage? {
        switch type {
        case "Following": return legacyIcon("person.crop.circle.badge.checkmark")
        case "New Group": return legacyIcon("person.3.fill")
        case "New Player": return legacyIcon("person.fill.badge.plus")
        case "Request Accepted 2": return legacyIcon("person.fill.checkmark")
        case "Request Sent": return legacyIcon("person.badge.plus")
        case "Set Workout": return legacyIcon("plus.circle.fill")
        default: return UIImage(named: type)
        }
    }

    private static func renderSquare(_ systemName: String, colour: UIColor, traits: UITraitCollection) -> UIImage {
        let side: CGFloat = 96
        let inset: CGFloat = 12
        let configuration = UIImage.SymbolConfiguration(pointSize: side, weight: .regular)
        let symbol = UIImage(systemName: systemName, withConfiguration: configuration)!
            .withTintColor(colour, renderingMode: .alwaysOriginal)
        let box = side - inset * 2
        let scale = min(box / symbol.size.width, box / symbol.size.height)
        let size = CGSize(width: symbol.size.width * scale, height: symbol.size.height * scale)
        let origin = CGPoint(x: (side - size.width) / 2, y: (side - size.height) / 2)
        let format = UIGraphicsImageRendererFormat(for: traits)
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            symbol.draw(in: CGRect(origin: origin, size: size))
        }
    }
}
