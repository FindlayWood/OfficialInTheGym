//
//  SportSessionDetailView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/03/2026.
//

import SwiftUI

struct SportSessionDetailView: View {
    
    @ObservedObject var manager: MyDayNewSportManager
    @State private var showingNoteSheet: Bool = false
    @State private var showingDurationPicker: Bool = false
    @State private var showingPlayingTimePicker: Bool = false
    
    private var isValid: Bool {
        switch manager.sessionType {
        case .training: return manager.duration > 0
        case .game:     return manager.duration > 0 && manager.playingTime > 0
        }
    }
    
    var addAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Sport header ───────────────────────────────────────────
            sportHeader
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    
                    // ── Session type picker ────────────────────────────
                    sessionTypePicker
                    
                    // ── Duration fields ────────────────────────────────
                    sectionCard {
                        if manager.sessionType == .game {
                            gameDurationRow
                            Divider().padding(.horizontal, 14)
                            playingTimeRow
                        } else {
                            trainingDurationRow
                        }
                    }
                    
                    // ── Game result (game only) ────────────────────────
                    if manager.sessionType == .game {
                        resultSection
                    }
                    
                    // ── RPE + Note ─────────────────────────────────────
                    sectionCard {
                        rpeRow
                        Divider().padding(.horizontal, 14)
                        noteRow
                    }
                    
                    // ── Session load ───────────────────────────────────
                    if let load = manager.sessionLoad {
                        sessionLoadCard(load: load)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            
            Divider()
            
            // ── Save button ────────────────────────────────────────────
            Button {
                addAction?()
            } label: {
                Text(saveButtonLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValid
                            ? manager.sport.color
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(manager.sport.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDurationPicker) {
            SportTimeSelectorView(
                title: manager.sessionType == .game ? "Game Duration" : "Session Duration",
                subtitle: manager.sessionType == .game ? "Total length of the game" : "How long was your session?",
                currentValue: manager.sessionType == .game ? manager.duration : manager.duration,
                color: manager.sport.color
            ) { value in
                manager.duration = value
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingPlayingTimePicker) {
            SportTimeSelectorView(
                title: "Playing Time",
                subtitle: "How long did you actually play?",
                currentValue: manager.playingTime,
                color: manager.sport.color
            ) { value in
                manager.playingTime = value
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingNoteSheet) {
            SportNoteSelectorView(manager: manager) {
                showingNoteSheet = false
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Sport Header
    
    private var sportHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(manager.sport.color.opacity(0.12))
                        .frame(width: 60, height: 60)
                    Image(systemName: manager.sport.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(manager.sport.color)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(manager.sport.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("Log your session details")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            Divider()
        }
    }
    
    // MARK: - Session Type Picker
    
    private var sessionTypePicker: some View {
        HStack(spacing: 10) {
            ForEach(SportSessionType.allCases, id: \.self) { type in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        manager.sessionType = type
                        // Reset duration fields when switching
                        manager.duration = 0
                        manager.playingTime = 0
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: type.icon)
                            .font(.system(size: 14, weight: .semibold))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(type.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                            Text(type.description)
                                .font(.system(size: 10, weight: .regular))
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(
                        manager.sessionType == type
                            ? Color.white
                            : Color.primary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .background(
                        manager.sessionType == type
                            ? manager.sport.color
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                manager.sessionType == type
                                    ? Color.clear
                                    : Color(UIColor.separator),
                                lineWidth: 0.5
                            )
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Duration Rows
    
    private var trainingDurationRow: some View {
        Button { showingDurationPicker = true } label: {
            durationRowContent(
                icon: "clock.fill",
                title: "Duration",
                subtitle: "Required",
                value: manager.duration,
                placeholder: "Set duration"
            )
        }
        .buttonStyle(.plain)
    }
    
    private var gameDurationRow: some View {
        Button { showingDurationPicker = true } label: {
            durationRowContent(
                icon: "clock.fill",
                title: "Game Duration",
                subtitle: "Total length of game · Required",
                value: manager.duration,
                placeholder: "Set game duration"
            )
        }
        .buttonStyle(.plain)
    }
    
    private var playingTimeRow: some View {
        Button { showingPlayingTimePicker = true } label: {
            durationRowContent(
                icon: "figure.run",
                title: "Playing Time",
                subtitle: "Your actual time on the field/court · Required",
                value: manager.playingTime,
                placeholder: "Set playing time"
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func durationRowContent(
        icon: String,
        title: String,
        subtitle: String,
        value: Int,
        placeholder: String
    ) -> some View {
        HStack(spacing: 14) {
            rowIcon(systemName: icon, color: manager.sport.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(subtitle)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Text(value > 0 ? formattedDuration(value) : placeholder)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        value > 0
                            ? manager.sport.color
                            : Color(UIColor.tertiaryLabel)
                    )
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("Result")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Text("· Optional")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
            }
            
            HStack(spacing: 10) {
                ForEach(GameResult.allCases, id: \.self) { result in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if manager.result == result {
                                manager.result = nil
                            } else {
                                manager.result = result
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: result.icon)
                                .font(.system(size: 13, weight: .semibold))
                            Text(result.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(
                            manager.result == result
                                ? Color.white
                                : result.color
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            manager.result == result
                                ? result.color
                                : result.color.opacity(0.08)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    manager.result == result
                                        ? Color.clear
                                        : result.color.opacity(0.3),
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Score input
            if manager.result != nil {
                HStack(spacing: 12) {
                    scoreField(label: "Your Score", value: $manager.homeScore)
                    Text("–")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.secondary)
                    scoreField(label: "Their Score", value: $manager.awayScore)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: manager.result)
    }
    
    @ViewBuilder
    private func scoreField(label: String, value: Binding<Int?>) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.secondary)
            
            HStack(spacing: 8) {
                Button {
                    let current = value.wrappedValue ?? 0
                    value.wrappedValue = max(0, current - 1)
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.secondary)
                        .frame(width: 32, height: 32)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Text("\(value.wrappedValue ?? 0)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .frame(minWidth: 36)
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.15), value: value.wrappedValue)
                
                Button {
                    value.wrappedValue = (value.wrappedValue ?? 0) + 1
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.white)
                        .frame(width: 32, height: 32)
                        .background(manager.sport.color)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - RPE Row
    
    private var rpeRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                rowIcon(systemName: "gauge.with.dots.needle.67percent", color: .orange)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Effort (RPE)")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Optional · How hard did it feel?")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                if let rpe = manager.rpe {
                    Text("\(rpe)/10")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(rpeColor(rpe))
                } else {
                    Text("Not set")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { value in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                manager.rpe = manager.rpe == value ? nil : value
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    manager.rpe != nil && value <= (manager.rpe ?? 0)
                                        ? rpeColor(value)
                                        : Color(UIColor.tertiarySystemBackground)
                                )
                                .frame(height: 28)
                                .overlay {
                                    if manager.rpe == value {
                                        Text("\(value)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(Color.white)
                                    }
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                HStack {
                    Text("Easy")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Text("Max effort")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 14)
        }
    }
    
    // MARK: - Note Row
    
    private var noteRow: some View {
        Button { showingNoteSheet = true } label: {
            HStack(spacing: 14) {
                rowIcon(systemName: "note.text", color: .purple)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Note")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Optional")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                Spacer()
                HStack(spacing: 6) {
                    if let note = manager.note, !note.isEmpty {
                        Text(note)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 120, alignment: .trailing)
                    } else {
                        Text("Add")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Session Load Card
    
    private func sessionLoadCard(load: Double) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.orange.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.orange)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Session Load")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(manager.sessionType == .game
                     ? "Playing time × RPE"
                     : "Duration × RPE"
                )
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            Spacer()
            Text(load.formatted(.number.precision(.fractionLength(0...1))))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.orange)
        }
        .padding(14)
        .background(Color.orange.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.orange.opacity(0.2), lineWidth: 1)
        }
    }
    
    // MARK: - Shared Helpers
    
    @ViewBuilder
    private func rowIcon(systemName: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.12))
                .frame(width: 36, height: 36)
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(color)
        }
    }
    
    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func rpeColor(_ value: Int) -> Color {
        switch value {
        case 1...3: return .green
        case 4...6: return .orange
        case 7...8: return .red
        default:    return Color(red: 0.6, green: 0, blue: 0)
        }
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return s == 0 ? "\(h)h \(m)m" : "\(h)h \(m)m \(s)s" }
        if m > 0 { return s == 0 ? "\(m)m" : "\(m)m \(s)s" }
        return "\(s)s"
    }
    
    private var saveButtonLabel: String {
        guard isValid else {
            switch manager.sessionType {
            case .training: return "Set a duration to continue"
            case .game:     return manager.duration == 0 ? "Set game duration to continue" : "Set playing time to continue"
            }
        }
        switch manager.sessionType {
        case .training: return "Save Training Session"
        case .game:     return "Save Game"
        }
    }
}

#Preview {
    SportSessionDetailView(manager: MyDayNewSportManager(sport: .americanFootball))
}
