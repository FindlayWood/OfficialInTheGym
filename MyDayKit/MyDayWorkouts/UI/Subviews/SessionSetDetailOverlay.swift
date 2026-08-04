//
//  SessionSetDetailOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 30/06/2026.
//

import SwiftUI

struct SessionSetDetailOverlay: View {

    @State private var isShowing: Bool = false
    @State private var hasSeededInputs: Bool = false
    @State private var repsInput: String = ""
    @State private var weightInput: String = ""
    @State private var weightUnitInput: WeightUnit = .kg
    @State private var timeInput: String = ""
    @State private var distanceInput: String = ""

    @State private var editingMeasure: SessionSetMeasure?

    let detail: SessionSetDetail
    let isSessionActive: Bool
    let animation: Namespace.ID
    var onLog: ((SessionSetInput) -> Void)?
    var onRemoveLog: (() -> Void)?
    var onDismiss: (() -> Void)?

    private var isLogged: Bool { detail.setRecord?.isCompleted ?? false }

    /// Something has to have been entered. Bodyweight counts on its own — it
    /// states what was performed without carrying a number.
    private var canLog: Bool {
        input.reps != nil
            || input.weight != nil
            || input.time != nil
            || input.distance != nil
            || input.weightUnit?.carriesValue == false
    }

    /// A bodyweight set is stated by its unit alone and carries no number;
    /// otherwise the unit only means something once there is a weight.
    private var input: SessionSetInput {
        let weight = weightUnitInput.carriesValue ? Double(weightInput) : nil
        return SessionSetInput(
            reps: Int(repsInput),
            weight: weight,
            weightUnit: weightUnitInput.carriesValue ? (weight != nil ? weightUnitInput : nil) : weightUnitInput,
            time: Int(timeInput),
            distance: Double(distanceInput)
        )
    }

    /// A tempo of all zeros is the builder's empty default, not a prescription.
    private var visibleTempo: Tempo? {
        guard let tempo = detail.setModel.tempo else { return nil }
        let isEmpty = tempo.eccentric == 0
            && tempo.eccentricHold == 0
            && tempo.concentric == 0
            && tempo.concentricHold == 0
        return isEmpty ? nil : tempo
    }

    private var visibleNote: String? {
        guard let note = detail.setModel.note else { return nil }
        return note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
    }

    var body: some View {
        VStack(spacing: 0) {
            if isShowing {
                header
                Divider()
                content
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .matchedGeometryEffect(id: "\(detail.matchedId)background", in: animation)
                .foregroundStyle(Color(UIColor.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(detail.matchedId)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            seedInputs()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowing = true
                }
            }
        }
        .sheet(item: $editingMeasure) { measure in
            SessionSetValueSheet(
                measure: measure,
                exerciseName: detail.exercise.exerciseName,
                setNumber: detail.index + 1,
                unitLabel: sheetUnitLabel(for: measure),
                targetSummary: targetSummary(for: measure),
                value: binding(for: measure),
                weightUnit: measure == .weight ? $weightUnitInput : nil
            )
            .presentationDetents([.height(measure == .weight ? 620 : 560)])
        }
    }

    // MARK: - Measure Plumbing

    private func binding(for measure: SessionSetMeasure) -> Binding<String> {
        switch measure {
        case .reps:     return $repsInput
        case .weight:   return $weightInput
        case .time:     return $timeInput
        case .distance: return $distanceInput
        }
    }

    /// The sheet only opens during an active session, so it always reflects the
    /// live selection rather than whatever the record was written with.
    private func sheetUnitLabel(for measure: SessionSetMeasure) -> String? {
        switch measure {
        case .reps:     return nil
        case .weight:   return weightUnitInput.rawValue
        case .time:     return "sec"
        case .distance: return detail.setModel.distanceUnit?.rawValue ?? "m"
        }
    }

    private func targetSummary(for measure: SessionSetMeasure) -> String? {
        switch measure {
        case .reps:
            return detail.setModel.reps.map { "\($0) \($0 == 1 ? "rep" : "reps")" }
        case .weight:
            guard let weight = detail.setModel.weight else { return nil }
            return "\(Self.formatDouble(weight)) \(detail.setModel.weightUnit?.rawValue ?? "kg")"
        case .time:
            guard let time = detail.setModel.time else { return nil }
            let m = time / 60; let s = time % 60
            return m > 0 ? "\(m)m \(s)s" : "\(s)s"
        case .distance:
            guard let distance = detail.setModel.distance else { return nil }
            return "\(Self.formatDouble(distance)) \(detail.setModel.distanceUnit?.rawValue ?? "m")"
        }
    }

    // MARK: - Seeding

    /// Pre-fill from the logged record if there is one, otherwise from the
    /// target. Runs once so a re-render after logging never overwrites typing.
    private func seedInputs() {
        guard !hasSeededInputs else { return }
        hasSeededInputs = true

        let record = detail.setRecord
        repsInput = (record?.reps ?? detail.setModel.reps).map { "\($0)" } ?? ""
        timeInput = (record?.time ?? detail.setModel.time).map { "\($0)" } ?? ""
        distanceInput = (record?.distance ?? detail.setModel.distance).map { Self.formatDouble($0) } ?? ""

        weightUnitInput = WeightUnit.loggableDefault(for: record?.weightUnit ?? detail.setModel.weightUnit)
        weightInput = record?.weight.map { Self.formatDouble($0) } ?? targetWeightInput
    }

    /// The target's weight, but only when the session is logging in the unit
    /// the target was written in. "80" prescribed as `% of 1RM` is not 80 kg,
    /// and a bodyweight set carries no number at all — seeding either would put
    /// a number the user never chose behind the "Complete Set" button.
    private var targetWeightInput: String {
        guard weightUnitInput.carriesValue else { return "" }
        guard detail.setModel.weightUnit == nil || detail.setModel.weightUnit == weightUnitInput else { return "" }
        return detail.setModel.weight.map { Self.formatDouble($0) } ?? ""
    }

    /// After un-logging, the fields should show the target again rather than
    /// the values that were just discarded.
    private func resetInputsToTarget() {
        repsInput = detail.setModel.reps.map { "\($0)" } ?? ""
        weightUnitInput = WeightUnit.loggableDefault(for: detail.setModel.weightUnit)
        weightInput = targetWeightInput
        timeInput = detail.setModel.time.map { "\($0)" } ?? ""
        distanceInput = detail.setModel.distance.map { Self.formatDouble($0) } ?? ""
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
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onDismiss?()
                }
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                measureGrid

                // Both are prescribed on the template set, so they sit with the
                // measures rather than with what was performed.
                if let tempo = visibleTempo {
                    tempoCard(tempo: tempo)
                }

                if let note = visibleNote {
                    noteCard(note: note)
                }

                if isSessionActive {
                    logButton
                    if isLogged {
                        removeLogButton
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Measure Grid

    /// One card per measure, showing what was performed with the target beside
    /// it. Target and performed were once two separate grids of four cards
    /// each; folding them together is what keeps the overlay off a long scroll
    /// now that every measure is editable.
    private var measureGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(gridTitle)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                    .tracking(1.2)
                if isLogged {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.green)
                }
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(visibleMeasures) { measure in
                    measureCard(measure)
                }
            }
        }
    }

    private var gridTitle: String {
        if isLogged { return "LOGGED" }
        return isSessionActive ? "PERFORMED" : "NOT LOGGED"
    }

    /// Only the measures the set actually uses. Weight is always offered: the
    /// commonest thing a user records beyond the prescription is a load the
    /// template never specified — a vest, a dumbbell, a loaded carry.
    private var visibleMeasures: [SessionSetMeasure] {
        var measures: [SessionSetMeasure] = []
        if detail.setModel.reps != nil || detail.setRecord?.reps != nil {
            measures.append(.reps)
        }
        measures.append(.weight)
        if detail.setModel.time != nil || detail.setRecord?.time != nil {
            measures.append(.time)
        }
        if detail.setModel.distance != nil || detail.setRecord?.distance != nil {
            measures.append(.distance)
        }
        return measures
    }

    private func measureCard(_ measure: SessionSetMeasure) -> some View {
        let value = displayValue(for: measure)
        let bracket = bracketTarget(for: measure)

        return Button {
            editingMeasure = measure
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Image(systemName: measure.icon)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                    Text(measure.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                    if let unit = cardUnitLabel(for: measure) {
                        Text(unit)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                    Spacer(minLength: 0)
                    if isSessionActive {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }

                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text(value.isEmpty ? "—" : value)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(value.isEmpty ? Color(UIColor.tertiaryLabel) : Color.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    if let bracket {
                        Text("(\(bracket))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isSessionActive)
    }

    // MARK: - Card Values

    /// What the card shows as performed. During a session that is the live
    /// input; once read-only it is whatever the record holds, so a set left
    /// unlogged in a finished session shows "—" rather than the target it
    /// never actually met.
    private func displayValue(for measure: SessionSetMeasure) -> String {
        if isSessionActive {
            switch measure {
            case .reps:     return repsInput
            case .weight:   return weightUnitInput.carriesValue ? weightInput : weightUnitInput.rawValue
            case .time:     return timeInput
            case .distance: return distanceInput
            }
        }

        guard let record = detail.setRecord, record.isCompleted else { return "" }
        switch measure {
        case .reps:
            return record.reps.map { "\($0)" } ?? ""
        case .weight:
            if let unit = record.weightUnit, !unit.carriesValue { return unit.rawValue }
            return record.weight.map { Self.formatDouble($0) } ?? ""
        case .time:
            return record.time.map { "\($0)" } ?? ""
        case .distance:
            return record.distance.map { Self.formatDouble($0) } ?? ""
        }
    }

    private func cardUnitLabel(for measure: SessionSetMeasure) -> String? {
        switch measure {
        case .reps:
            return nil
        case .weight:
            let unit = isSessionActive ? weightUnitInput : detail.setRecord?.weightUnit
            guard let unit, unit.carriesValue else { return nil }
            return unit.rawValue
        case .time:
            return "sec"
        case .distance:
            return detail.setModel.distanceUnit?.rawValue ?? "m"
        }
    }

    /// The target, shown beside the performed value only when the two differ —
    /// an on-target set stays clean, so the bracket is what catches the eye.
    private func bracketTarget(for measure: SessionSetMeasure) -> String? {
        guard let target = targetText(for: measure) else { return nil }
        return target == comparableValue(for: measure) ? nil : target
    }

    private func targetText(for measure: SessionSetMeasure) -> String? {
        switch measure {
        case .reps:
            return detail.setModel.reps.map { "\($0)" }
        case .weight:
            // Carries its unit because the prescription may be in one the
            // session cannot log — "(80 % of 1RM)" beside a logged 100 kg is
            // exactly the reference the user is working from.
            if let unit = detail.setModel.weightUnit, !unit.carriesValue { return unit.rawValue }
            guard let weight = detail.setModel.weight else { return nil }
            guard let unit = detail.setModel.weightUnit else { return Self.formatDouble(weight) }
            return "\(Self.formatDouble(weight)) \(unit.rawValue)"
        case .time:
            return detail.setModel.time.map { "\($0)" }
        case .distance:
            return detail.setModel.distance.map { Self.formatDouble($0) }
        }
    }

    /// The performed value rendered the way `targetText` renders the target, so
    /// the two can be compared without the unit causing a false difference.
    private func comparableValue(for measure: SessionSetMeasure) -> String {
        guard measure == .weight else { return displayValue(for: measure) }

        let unit = isSessionActive ? weightUnitInput : detail.setRecord?.weightUnit
        guard let unit else { return displayValue(for: .weight) }
        guard unit.carriesValue else { return unit.rawValue }

        let value = displayValue(for: .weight)
        return value.isEmpty ? "" : "\(value) \(unit.rawValue)"
    }

    // MARK: - Remove Log

    private var removeLogButton: some View {
        Button {
            onRemoveLog?()
            resetInputsToTarget()
        } label: {
            Text("Remove Log")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.red.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tempo Card

    /// Mirrors `SetDetailView.tempoCard` — the two set detail views are kept
    /// visually in step.
    private func tempoCard(tempo: Tempo) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(systemName: "waveform.path")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Tempo")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }

            HStack(spacing: 0) {
                ForEach(
                    [
                        ("Ecc", "\(tempo.eccentric)"),
                        ("Hold", "\(tempo.eccentricHold)"),
                        ("Con", "\(tempo.concentric)"),
                        ("Hold", "\(tempo.concentricHold)")
                    ],
                    id: \.0
                ) { phase, value in
                    VStack(spacing: 4) {
                        Text(value)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.primary)
                        Text(phase)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    if phase != "Hold" {
                        Text("–")
                            .font(.system(size: 16, weight: .light))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Note Card

    private func noteCard(note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: "note.text")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Note")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            Text(note)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Log Button

    private var logButton: some View {
        Button {
            onLog?(input)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text(isLogged ? "Update Set" : "Complete Set")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(canLog ? Color.white : Color.secondary)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(canLog ? Color.darkColor : Color(UIColor.tertiarySystemFill))
            )
        }
        .buttonStyle(.plain)
        .disabled(!canLog)
        .animation(.easeInOut(duration: 0.15), value: canLog)
    }

    // MARK: - Helpers

    private static func formatDouble(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(v))" : "\(v)"
    }
}
