//
//  SessionSetDetailOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/06/2026.
//

import SwiftUI

struct SessionSetDetailOverlay: View {

    let detail: SessionSetDetail
    let isSessionActive: Bool
    var onComplete: (() -> Void)?
    var onDismiss: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(UIColor.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(detail.exercise.exerciseName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text("Set \(detail.index + 1)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Button {
                onDismiss?()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color(UIColor.secondarySystemBackground))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 12) {
            targetGrid

            if let record = detail.setRecord, record.isCompleted {
                loggedGrid(record: record)
            }

            if (detail.setRecord?.isCompleted ?? false) == false, isSessionActive {
                completeButton
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Target Grid

    private var targetGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("TARGET")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .tracking(1.2)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statCard(label: "Reps", value: detail.setModel.reps.map { "\($0)" } ?? "—", icon: "repeat")
                weightCard(weight: detail.setModel.weight, unit: detail.setModel.weightUnit)
                timeCard(time: detail.setModel.time)
                distanceCard(distance: detail.setModel.distance, unit: detail.setModel.distanceUnit)
            }
        }
    }

    // MARK: - Logged Grid

    private func loggedGrid(record: WorkoutSetRecord) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("LOGGED")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.green)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statCard(label: "Reps", value: record.reps.map { "\($0)" } ?? "—", icon: "repeat", highlight: true)
                weightCard(weight: record.weight, unit: record.weightUnit, highlight: true)
                timeCard(time: record.time, highlight: true)
                distanceCard(distance: record.distance, unit: record.distanceUnit, highlight: true)
            }
        }
    }

    // MARK: - Stat Cards

    private func statCard(
        label: String,
        value: String,
        icon: String,
        highlight: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
            }
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func weightCard(weight: Double?, unit: WeightUnit?, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "scalemass")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
                Text("Weight")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
            }
            if let w = weight, let u = unit {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(w.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(w))" : "\(w)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(u.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func timeCard(time: Int?, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
                Text("Time")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
            }
            if let t = time {
                let m = t / 60; let s = t % 60
                Text(m > 0 ? "\(m)m \(s)s" : "\(s)s")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .minimumScaleFactor(0.8)
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func distanceCard(distance: Double?, unit: DistanceUnit?, highlight: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "ruler")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
                Text("Distance")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.darkColor : Color.secondary)
            }
            if let d = distance, let u = unit {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))" : "\(d)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(u.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button {
            onComplete?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text("Complete Set")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.darkColor)
            )
        }
        .buttonStyle(.plain)
    }
}
