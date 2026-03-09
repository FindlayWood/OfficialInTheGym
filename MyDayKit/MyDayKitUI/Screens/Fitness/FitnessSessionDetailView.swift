//
//  FitnessSessionDetailView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/03/2026.
//

import SwiftUI

// MARK: - Manager

class MyDayNewFitnessManager: ObservableObject, Hashable {
    
    let activity: FitnessActivityType
    
    @Published var duration: Int = 0        // seconds
    @Published var distance: Double?
    @Published var distanceUnits: DistanceUnit?
    @Published var rpe: Int?
    @Published var note: String?
    
    var sessionLoad: Double? {
        guard let rpe, duration > 0 else { return nil }
        let minutes = Double(duration) / 60.0
        return minutes * Double(rpe)
    }
    
    init(activity: FitnessActivityType) {
        self.activity = activity
    }
    
    // MARK: - Hashable
    static func == (lhs: MyDayNewFitnessManager, rhs: MyDayNewFitnessManager) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

// MARK: - View

struct FitnessSessionDetailView: View {
    
    @ObservedObject var manager: MyDayNewFitnessManager
    @State private var showingNoteSheet: Bool = false
    
    private var isValid: Bool { manager.duration > 0 }
    
    private var durationText: String {
        guard manager.duration > 0 else { return "Not set" }
        let minutes = manager.duration / 60
        let seconds = manager.duration % 60
        if seconds == 0 {
            return "\(minutes)m"
        } else {
            return "\(minutes)m \(seconds)s"
        }
    }
    
    var addAction: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Activity header ────────────────────────────────────────
            activityHeader
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    
                    // ── Duration (required) ────────────────────────────
                    sectionCard {
                        durationRow
                    }
                    
                    // ── Optional extras ────────────────────────────────
                    sectionCard {
                        VStack(spacing: 0) {
                            distanceRow
                            Divider().padding(.horizontal, 14)
                            rpeRow
                            Divider().padding(.horizontal, 14)
                            noteRow
                        }
                    }
                    
                    // ── Session load preview ───────────────────────────
                    if let load = manager.sessionLoad {
                        sessionLoadCard(load: load)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            
            Divider()
            
            // ── Add button ─────────────────────────────────────────────
            Button {
                addAction?()
            } label: {
                Text(isValid ? "Save Session" : "Set a duration to continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        isValid
                            ? manager.activity.color
                            : Color(UIColor.secondarySystemBackground)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationTitle(manager.activity.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNoteSheet) {
            MyDayNoteSelectorView(
                newExercise: .init(exercise: .pressUps), // swap with your note handler
                continueAction: { showingNoteSheet = false }
            )
            .presentationDetents([.medium, .large])
        }
    }
    
    // MARK: - Activity Header
    
    private var activityHeader: some View {
        Group {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(manager.activity.color.opacity(0.12))
                        .frame(width: 60, height: 60)
                    Image(systemName: manager.activity.icon)
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(manager.activity.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(manager.activity.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.primary)
                    Text("Fill in your session details")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(UIColor.systemBackground))
            
            Divider()
        }
    }
    
    // MARK: - Duration Row
    
    private var durationRow: some View {
        NavigationLink {
            FitnessTimeSelectorView(manager: manager)
        } label: {
            HStack(spacing: 14) {
                rowIcon(systemName: "clock.fill", color: manager.activity.color)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Duration")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Required")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text(durationText)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            manager.duration > 0
                                ? manager.activity.color
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
    }
    
    // MARK: - Distance Row
    
    private var distanceRow: some View {
        NavigationLink {
            FitnessDistanceSelectorView(manager: manager)
        } label: {
            HStack(spacing: 14) {
                rowIcon(systemName: "ruler.fill", color: .blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Distance")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.primary)
                    Text("Optional")
                        .font(.system(size: 11, weight: .regular))
                        .foregroundStyle(Color.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    if let distance = manager.distance,
                       let unit = manager.distanceUnits {
                        Text("\(distance.formatted(.number.precision(.fractionLength(0...2)))) \(unit.rawValue)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.blue)
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
            
            // RPE Slider
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { value in
                        Button {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                if manager.rpe == value {
                                    manager.rpe = nil
                                } else {
                                    manager.rpe = value
                                }
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
        Button {
            showingNoteSheet = true
        } label: {
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
                Text("Duration × RPE — used for workload tracking")
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
    
    // MARK: - Shared row icon
    
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
    
    // MARK: - Section Card
    
    @ViewBuilder
    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - RPE colour
    
    private func rpeColor(_ value: Int) -> Color {
        switch value {
        case 1...3: return .green
        case 4...6: return .orange
        case 7...8: return .red
        default:    return Color(red: 0.6, green: 0, blue: 0)
        }
    }
}

#Preview {
    FitnessSessionDetailView(manager: MyDayNewFitnessManager(activity: .boxing))
}
