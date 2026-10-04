//
//  BodyMeasurementsViewModel.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import Combine
import Foundation

/// Body Measurements: height and date of birth, plus the weight log
/// (`PROFILE_PLAN.md` step 4). Private to the user, reached from Settings, and
/// deliberately not on Edit Profile, which edits what other people see.
///
/// **Height and date of birth save when their sheet closes.** The sheets bind
/// live and Done only dismisses, the contract `AccountCreationPickerSheet` set.
/// What the wheel shows is the value, so closing the sheet is the moment to
/// keep it. A wheel scrolled through five values in passing writes once, not
/// five times. `lastSaved` is what the server holds, so a close with no change
/// writes nothing.
///
/// **Weight is logged, not edited.** Each log writes today's entry, replacing
/// an earlier one from the same day. The log shows at once and is put back if
/// the write fails, as DISCOVER's likes do, because the trend line jumping
/// while a spinner turns is worse than a rare revert with an error.
///
/// A failed load is a state with Try Again, never an empty log. "No weight
/// logged" said to someone who has logged for months is the empty-library bug
/// again.
@MainActor
final class BodyMeasurementsViewModel: ObservableObject {

    enum LoadState: Equatable {
        case loading
        case loaded
        case failed
    }

    static let historyLimit = 60

    @Published private(set) var loadState: LoadState = .loading
    @Published var measurements = BodyMeasurements()
    @Published private(set) var entries: [WeightEntry] = []
    @Published private(set) var errorMessage: String?

    private var lastSaved = BodyMeasurements()

    private let measurementsLoader: BodyMeasurementsLoader
    private let measurementsWriter: BodyMeasurementsWriter
    private let logLoader: WeightLogLoader
    private let entryWriter: WeightEntryWriter
    private let entryRemover: WeightEntryRemover
    private let now: () -> Date

    init(
        measurementsLoader: BodyMeasurementsLoader,
        measurementsWriter: BodyMeasurementsWriter,
        logLoader: WeightLogLoader,
        entryWriter: WeightEntryWriter,
        entryRemover: WeightEntryRemover,
        now: @escaping () -> Date = Date.init
    ) {
        self.measurementsLoader = measurementsLoader
        self.measurementsWriter = measurementsWriter
        self.logLoader = logLoader
        self.entryWriter = entryWriter
        self.entryRemover = entryRemover
        self.now = now
    }

    // MARK: - Derived

    var latest: WeightEntry? { entries.first }

    /// Weights read in the unit of the latest entry, falling back to the
    /// signup preference, then kilograms.
    var weightUnit: ProfileWeightUnit {
        latest?.unit ?? measurements.weightUnit ?? .kilograms
    }

    var heightUnit: ProfileHeightUnit {
        measurements.heightUnit ?? .centimetres
    }

    var heightText: String? {
        measurements.heightCentimetres.map { ProfileHeightUnit.display(centimetres: $0, in: heightUnit) }
    }

    var dateOfBirthText: String? {
        measurements.dateOfBirth.map { $0.formatted(date: .long, time: .omitted) }
    }

    /// Whether today already has an entry, so the button can say "Update".
    var hasLoggedToday: Bool {
        latest?.id == WeightDay.key(for: now())
    }

    // MARK: - Load

    func load() async {
        loadState = .loading
        do {
            async let measurements = measurementsLoader.load()
            async let entries = logLoader.load(limit: Self.historyLimit)
            let (loadedMeasurements, loadedEntries) = try await (measurements, entries)
            self.measurements = loadedMeasurements
            lastSaved = loadedMeasurements
            self.entries = loadedEntries
            loadState = .loaded
        } catch {
            print("❌ Body measurements failed: \(error)")
            loadState = .failed
        }
    }

    // MARK: - Height and date of birth

    /// Called when a height or date-of-birth sheet closes.
    func saveMeasurementsIfChanged() async {
        guard measurements != lastSaved else { return }
        let toSave = measurements
        errorMessage = nil
        do {
            try await measurementsWriter.save(toSave)
            lastSaved = toSave
        } catch {
            print("❌ Body measurements save failed: \(error)")
            // Put the screen back to what the server holds, so nothing on it
            // claims a value that was never saved.
            measurements = lastSaved
            errorMessage = "Couldn't save that change. Check your connection and try again."
        }
    }

    // MARK: - Weight

    func logWeight(kilograms: Double, unit: ProfileWeightUnit) async {
        let entry = WeightDay.entry(kilograms: kilograms, unit: unit, on: now())
        let previous = entries
        entries = [entry] + entries.filter { $0.id != entry.id }
        errorMessage = nil
        do {
            try await entryWriter.log(entry)
        } catch {
            print("❌ Weight log failed: \(error)")
            entries = previous
            errorMessage = "Couldn't log your weight. Check your connection and try again."
        }
    }

    func deleteEntry(_ entry: WeightEntry) async {
        let previous = entries
        entries.removeAll { $0.id == entry.id }
        errorMessage = nil
        do {
            try await entryRemover.remove(entryId: entry.id)
        } catch {
            print("❌ Weight delete failed: \(error)")
            entries = previous
            errorMessage = "Couldn't delete that entry. Check your connection and try again."
        }
    }
}
