//
//  SetDetailView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

/// The MyDay home screen's set detail card.
///
/// Drawn to match `SessionSetDetailOverlay` — same header, same "LOGGED"
/// section label, same measure grid in the same order, same card chrome — so a
/// set logged on its own and a set logged inside a workout are read the same
/// way. **Keep the two in step.**
///
/// What it deliberately does **not** copy is how editing works. The session
/// overlay edits every measure inline through `SessionSetValueSheet`; here the
/// whole set is edited by re-entering the logging flow behind the Edit button,
/// which is why there are no chevrons on the cards and no inline sheets. That
/// difference is the existing behaviour and is preserved exactly.
struct SetDetailView: View {

    @State private var isShowing: Bool = false
    @State private var isShowingDelete: Bool = false

    /// Position of this set within its exercise, for the "Set N" subtitle.
    let index: Int
    let model: ExerciseCompletions
    let animation: Namespace.ID
    let isToday: Bool
    var close: (() -> ())?
    var edit: (() -> ())?
    var delete: (() -> ())?

    var body: some View {
        VStack(spacing: 0) {
            if isShowing {
                
                // ── Header ─────────────────────────────────────────────
                header
                
                if isShowingDelete {
                    deleteConfirmation
                } else {
                    mainContent
                }
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .matchedGeometryEffect(id: "\(model.id)background", in: animation)
                .foregroundStyle(Color(UIColor.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .inset(by: 0.5)
                        .stroke(Color(UIColor.separator), lineWidth: 0.5)
                        .matchedGeometryEffect(id: "\(model.id)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowing = true
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(model.exercise.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                // "Set N" as the session overlay writes it, with the time this
                // view has always shown kept alongside it.
                Text("Set \(index + 1) · \(formattedTime(from: model.dateCompleted))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowing = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    close?()
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
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {

                // ── Measure grid ───────────────────────────────────────
                measureGrid

                // ── Tempo ──────────────────────────────────────────────
                if let tempo = model.tempo {
                    tempoCard(tempo: tempo)
                }
                
                // ── Each side ──────────────────────────────────────────
                if model.eachSide ?? false {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.darkColor)
                        Text("Performed each side")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.darkColor.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // ── Note ───────────────────────────────────────────────
                if let note = model.note {
                    noteCard(note: note)
                }
                
                // ── Actions ────────────────────────────────────────────
                if isToday {
                    actionButtons
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Measure Grid

    /// Mirrors `SessionSetDetailOverlay.measureGrid`: a section label over a
    /// two-column grid with one card per measure, in the session's order
    /// (reps → weight → time → distance). Every completion here has by
    /// definition been performed, so the label is always "LOGGED" — this view
    /// has no unlogged state to title.
    private var measureGrid: some View {
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

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 10) {
                repsCard
                weightCard
                timeCard
                distanceCard
            }
        }
    }

    // MARK: - Card Chrome

    /// The session overlay's `cardHeader` / `cardBackground`, minus the chevron
    /// — nothing here is edited in place.
    private func cardHeader(icon: String, title: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.darkColor)
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.darkColor)
            Spacer(minLength: 0)
        }
    }

    private func cardBackground<Content: View>(_ content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    /// The em dash a measure the set never carried draws, so the grid keeps
    /// four cards rather than collapsing to whatever this set happened to use.
    private var emptyValue: some View {
        Text("—")
            .font(.system(size: 24, weight: .bold))
            .foregroundStyle(Color(UIColor.tertiaryLabel))
    }

    // MARK: - Measure Cards

    private var repsCard: some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 6) {
                cardHeader(icon: "repeat", title: "Reps")

                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(model.reps)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text(model.reps > 1 ? "reps" : "rep")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        )
    }

    private var weightCard: some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 6) {
                cardHeader(icon: "scalemass", title: "Weight")

                if let weight = model.weight, let unit = model.weightUnit {
                    if unit != .max, unit != .bw {
                        HStack(alignment: .lastTextBaseline, spacing: 3) {
                            Text(weight.formatted(.number.precision(.fractionLength(0...2))))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text(unit.rawValue)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.secondary)
                        }
                    } else {
                        // A bodyweight or max set is stated by its unit alone.
                        Text(unit.rawValue)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.primary)
                    }
                } else {
                    emptyValue
                }
            }
        )
    }

    private var timeCard: some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 6) {
                cardHeader(icon: "clock", title: "Time")

                if let time = model.time {
                    Text(displayTime(for: time))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.primary)
                        .minimumScaleFactor(0.8)
                } else {
                    emptyValue
                }
            }
        )
    }

    private var distanceCard: some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 6) {
                cardHeader(icon: "ruler", title: "Distance")

                if let distance = model.distance, let unit = model.distanceUnits {
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(distance.formatted(.number.precision(.fractionLength(0...2))))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(Color.primary)
                        Text(unit.rawValue)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.secondary)
                    }
                } else {
                    emptyValue
                }
            }
        )
    }

    // MARK: - Tempo Card
    
    private func tempoCard(tempo: Tempo) -> some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 10) {
                cardHeader(icon: "waveform.path", title: "Tempo")

                HStack(spacing: 0) {
                    ForEach(Array(Self.tempoPhases.enumerated()), id: \.offset) { position, phase in
                        VStack(spacing: 4) {
                            Text("\(tempo[keyPath: phase.keyPath])")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.primary)
                            Text(phase.label)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(Color.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        if position < Self.tempoPhases.count - 1 {
                            Text("–")
                                .font(.system(size: 16, weight: .light))
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                        }
                    }
                }
            }
        )
    }

    /// The four phases in the order a tempo is written, paired with where each
    /// one lives on `Tempo` — the same table `SessionSetDetailOverlay` uses.
    /// Indexed by position rather than keyed by label, because "Hold" appears
    /// twice and keying by it dropped a separator.
    private static let tempoPhases: [(label: String, keyPath: KeyPath<Tempo, Int>)] = [
        ("Ecc", \.eccentric),
        ("Hold", \.eccentricHold),
        ("Con", \.concentric),
        ("Hold", \.concentricHold)
    ]

    // MARK: - Note Card
    
    private func noteCard(note: String) -> some View {
        cardBackground(
            VStack(alignment: .leading, spacing: 8) {
                cardHeader(icon: "note.text", title: "Note")

                Text(note)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        )
    }

    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button {
                edit?()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Edit")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.darkColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingDelete = true
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Delete")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - Delete Confirmation
    
    private var deleteConfirmation: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 64, height: 64)
                Image(systemName: "trash.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Color.red)
            }
            
            VStack(spacing: 6) {
                Text("Delete this set?")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("This action cannot be undone.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Button {
                    delete?()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Delete Set")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isShowingDelete = false
                    }
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
    
    // MARK: - Helpers
    
    func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    SetDetailView(
        index: 0,
        model: .init(
            id: "",
            exercise: .pressUps,
            reps: 10,
            weight: 10,
            weightUnit: .kg,
            dateCompleted: .now,
            distance: 50,
            distanceUnits: .metres,
            time: 45,
            tempo: Tempo(),
            note: "This is s test note",
            eachSide: false
        ),
        animation: namespace,
        isToday: true
    )
    .padding()
}
