//
//  SetDetailView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct SetDetailView: View {
    
    @State private var isShowing: Bool = false
    @State private var isShowingDelete: Bool = false
    
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
                
                Text(formattedTime(from: model.dateCompleted))
                    .font(.system(size: 12, weight: .regular))
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
                
                // ── Stats grid ─────────────────────────────────────────
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    statCard(
                        label: "Reps",
                        value: "\(model.reps)",
                        unit: model.reps > 1 ? "reps" : "rep",
                        icon: "repeat",
                        highlight: true
                    )
                    
                    weightCard
                    distanceCard
                    timeCard
                }
                
                // ── Tempo ──────────────────────────────────────────────
                if let tempo = model.tempo {
                    tempoCard(tempo: tempo)
                }
                
                // ── Each side ──────────────────────────────────────────
                if model.eachSide ?? false {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.blue)
                        Text("Performed each side")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.primary)
                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.blue.opacity(0.08))
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
            .padding(.bottom, 24)
        }
    }
    
    // MARK: - Stat Cards
    
    private func statCard(
        label: String,
        value: String,
        unit: String? = nil,
        icon: String,
        highlight: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.blue : Color.secondary)
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(highlight ? Color.blue : Color.secondary)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.primary)
                if let unit {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var weightCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "scalemass")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Weight")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            
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
                    Text(unit.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
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
    
    private var distanceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "ruler")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Distance")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            
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
    
    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Time")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            
            if let time = model.time {
                Text(displayTime(for: time))
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
    
    // MARK: - Tempo Card
    
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
                .background(Color.blue)
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
