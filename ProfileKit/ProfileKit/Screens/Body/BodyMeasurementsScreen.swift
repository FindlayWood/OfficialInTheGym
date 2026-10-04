//
//  BodyMeasurementsScreen.swift
//  ProfileKit
//
//  Created by Findlay Wood on 03/10/2026.
//

import SwiftUI

/// Body Measurements, pushed from Settings. See `BodyMeasurementsViewModel`.
///
/// Two sections: the fixed facts (height, date of birth) as the same rows
/// signup asked them in, and the weight log (latest reading, a Log button, the
/// trend line from two entries on, then the history).
///
/// The privacy line sits at the top, above the first section, not in a footer.
/// It is the first thing someone wonders on a screen asking for their weight,
/// and the answer is the reason this is not on Edit Profile.
struct BodyMeasurementsScreen: View {

    @ObservedObject var viewModel: BodyMeasurementsViewModel
    @State private var sheet: BodySheet?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                privacyNote
                switch viewModel.loadState {
                case .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                case .failed:
                    ProfileLoadFailedCard(title: "Couldn't Load Measurements") { Task { await viewModel.load() } }
                case .loaded:
                    if let message = viewModel.errorMessage {
                        ProfileErrorBanner(message: message)
                    }
                    bodySection
                    weightSection
                }
            }
            .padding(16)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Body Measurements")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
        .sheet(item: $sheet) { sheet in
            sheetContent(sheet)
                .presentationDetents([.height(sheet.detentHeight)])
                .tint(Color.darkColor)
                .onDisappear {
                    guard sheet.savesOnDismiss else { return }
                    Task { await viewModel.saveMeasurementsIfChanged() }
                }
        }
    }

    // MARK: - Privacy

    private var privacyNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
            Text("Only you can see these. They're never shown on your profile.")
                .font(.system(size: 13))
        }
        .foregroundStyle(Color.secondary)
        .padding(.horizontal, 4)
    }

    // MARK: - Body

    private var bodySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Body")
            BodyMeasurementRow(title: "Height", icon: "ruler", value: viewModel.heightText) {
                sheet = .height
            }
            BodyMeasurementRow(title: "Date of Birth", icon: "calendar", value: viewModel.dateOfBirthText) {
                sheet = .dateOfBirth
            }
        }
    }

    // MARK: - Weight

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("Weight")
            VStack(alignment: .leading, spacing: 16) {
                latestWeight
                if viewModel.entries.count >= 2 {
                    WeightTrendLine(entries: viewModel.entries, unit: viewModel.weightUnit)
                }
                Button {
                    sheet = .logWeight
                } label: {
                    Text(viewModel.hasLoggedToday ? "Update Today's Weight" : "Log Weight")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.darkColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )

            if !viewModel.entries.isEmpty {
                history
            }
        }
    }

    @ViewBuilder
    private var latestWeight: some View {
        if let latest = viewModel.latest {
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.weightUnit.display(kilograms: latest.weightKilograms))
                    .font(.system(size: 30, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color.primary)
                Text(viewModel.hasLoggedToday ? "Today" : "Last logged \(WeightDay.displayFormatter.string(from: latest.date))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
        } else {
            Text("No weight logged yet. Log it now and then, and the trend appears here.")
                .font(.system(size: 15))
                .foregroundStyle(Color.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle("History")
                .padding(.top, 8)
            VStack(spacing: 0) {
                ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                    WeightHistoryRow(
                        entry: entry,
                        unit: viewModel.weightUnit,
                        showsDivider: index < viewModel.entries.count - 1
                    ) {
                        Task { await viewModel.deleteEntry(entry) }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )
            Text("Press and hold an entry to delete it.")
                .font(.system(size: 12))
                .foregroundStyle(Color(.tertiaryLabel))
                .padding(.horizontal, 4)
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.secondary)
            .textCase(.uppercase)
            .tracking(0.8)
            .padding(.horizontal, 4)
    }

    // MARK: - Sheets

    @ViewBuilder
    private func sheetContent(_ sheet: BodySheet) -> some View {
        switch sheet {
        case .height:
            HeightPickerSheet(
                centimetres: $viewModel.measurements.heightCentimetres,
                unit: Binding(
                    get: { viewModel.heightUnit },
                    set: { viewModel.measurements.heightUnit = $0 }
                )
            )
        case .dateOfBirth:
            DateOfBirthSheet(dateOfBirth: $viewModel.measurements.dateOfBirth)
        case .logWeight:
            WeightLogSheet(
                initialKilograms: viewModel.latest?.weightKilograms,
                initialUnit: viewModel.weightUnit
            ) { kilograms, unit in
                Task { await viewModel.logWeight(kilograms: kilograms, unit: unit) }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BodyMeasurementsScreen(
            viewModel: BodyMeasurementsViewModel(
                measurementsLoader: PreviewBodyServices(),
                measurementsWriter: PreviewBodyServices(),
                logLoader: PreviewBodyServices(),
                entryWriter: PreviewBodyServices(),
                entryRemover: PreviewBodyServices()
            )
        )
    }
}
