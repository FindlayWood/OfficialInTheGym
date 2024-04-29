//
//  ErrorView.swift
//  ITGWorkoutKitiOS
//
//  Created by Findlay Wood on 29/04/2024.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var label: UILabel!

    public var message: String? {
        get { return label.text }
        set { label.text = newValue }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()

        label.text = nil
    }
}
