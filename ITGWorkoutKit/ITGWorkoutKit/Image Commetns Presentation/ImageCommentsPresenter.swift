//
//  ImageCommentsPresenter.swift
//  ITGWorkoutKit
//
//  Created by Findlay Wood on 20/06/2024.
//

import Foundation

public final class ImageCommentsPresenter {
    public static var title: String {
        NSLocalizedString("IMAGE_COMMENTS_VIEW_TITLE",
            tableName: "ImageComments",
            bundle: Bundle(for: Self.self),
            comment: "Title for the image comments view")
    }
}
