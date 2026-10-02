//
//  DiscoverRatingViewModel.swift
//  DiscoverKit
//
//  Created by Findlay Wood on 30/09/2026.
//

import Combine
import Foundation

/// The rating on a detail screen: the subject's summary, the user's own rating,
/// and setting it.
///
/// **Rating updates the screen before the server does.** The average is
/// recounted by a Cloud Function after the write lands, seconds later; holding
/// the old average until then would make the tap look ignored. The summary is
/// adjusted locally through `RatingSummary.replacingRating(_:with:)`, and a
/// failed write puts both the summary and the user's rating back.
///
/// `canRate` is false on the user's own workout. The security rules refuse
/// that write anyway; this keeps the screen from offering it.
@MainActor
final class DiscoverRatingViewModel: ObservableObject {

    @Published private(set) var summary: RatingSummary
    @Published private(set) var myRating: Int?
    @Published private(set) var didFailToSave = false
    @Published var isSheetPresented = false

    let subject: DiscoverSubject
    let canRate: Bool

    private let summaryLoader: RatingSummaryLoader
    private let myRatingLoader: MyRatingLoader
    private let writer: RatingWriter

    init(
        subject: DiscoverSubject,
        initialSummary: RatingSummary,
        canRate: Bool,
        summaryLoader: RatingSummaryLoader,
        myRatingLoader: MyRatingLoader,
        writer: RatingWriter
    ) {
        self.subject = subject
        self.summary = initialSummary
        self.canRate = canRate
        self.summaryLoader = summaryLoader
        self.myRatingLoader = myRatingLoader
        self.writer = writer
    }

    /// Refreshes the summary and reads the user's rating. A failure keeps the
    /// summary the screen opened with — stale is better than blank.
    func load() async {
        async let loadedSummary = loadSummary()
        async let loadedRating = loadMyRating()
        let (summary, rating) = await (loadedSummary, loadedRating)
        if let summary {
            self.summary = summary
        }
        if let rating {
            self.myRating = rating
        }
    }

    private func loadSummary() async -> RatingSummary? {
        try? await summaryLoader.summary(for: subject)
    }

    private func loadMyRating() async -> Int? {
        guard canRate else { return nil }
        return try? await myRatingLoader.myRating(for: subject)
    }

    func rate(_ rating: Int) async {
        guard canRate, rating != myRating else { return }
        let previousRating = myRating
        let previousSummary = summary

        myRating = rating
        summary = summary.replacingRating(previousRating, with: rating)
        didFailToSave = false

        do {
            try await writer.setRating(rating, for: subject)
        } catch {
            print("❌ Rating failed: \(error)")
            myRating = previousRating
            summary = previousSummary
            didFailToSave = true
        }
    }
}
