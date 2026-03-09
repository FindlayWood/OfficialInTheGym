//
//  FitnessActivityPickerView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 08/03/2026.
//

import SwiftUI

// MARK: - Model

enum FitnessActivityType: String, CaseIterable, Codable, Identifiable {
    case running      = "Running"
    case cycling      = "Cycling"
    case swimming     = "Swimming"
    case walking      = "Walking"
    case rowing       = "Rowing"
    case hiit         = "HIIT"
    case yoga         = "Yoga"
    case pilates      = "Pilates"
    case elliptical   = "Elliptical"
    case climbing     = "Climbing"
    case skipping     = "Skipping"
    case hiking       = "Hiking"
    case crossfit     = "CrossFit"
    case boxing       = "Boxing"
    case dancing      = "Dancing"
    case other        = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .running:    return "figure.run"
        case .cycling:    return "figure.outdoor.cycle"
        case .swimming:   return "figure.pool.swim"
        case .walking:    return "figure.walk"
        case .rowing:     return "figure.rowing"
        case .hiit:       return "bolt.heart.fill"
        case .yoga:       return "figure.yoga"
        case .pilates:    return "figure.pilates"
        case .elliptical: return "figure.elliptical"
        case .climbing:   return "figure.climbing"
        case .skipping:   return "figure.jumprope"
        case .hiking:     return "figure.hiking"
        case .crossfit:   return "dumbbell.fill"
        case .boxing:     return "figure.boxing"
        case .dancing:    return "figure.dance"
        case .other:      return "ellipsis.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .running:    return .blue
        case .cycling:    return .orange
        case .swimming:   return .cyan
        case .walking:    return .green
        case .rowing:     return .indigo
        case .hiit:       return .red
        case .yoga:       return .purple
        case .pilates:    return .pink
        case .elliptical: return .teal
        case .climbing:   return .brown
        case .skipping:   return .yellow
        case .hiking:     return .mint
        case .crossfit:   return .red
        case .boxing:     return .orange
        case .dancing:    return .purple
        case .other:      return .gray
        }
    }
}

// MARK: - View

struct FitnessActivityPickerView: View {
    
    @State private var searchText: String = ""
    @State private var selectedActivity: FitnessActivityType?
    @FocusState private var searchFocused: Bool
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var activitySelected: ((FitnessActivityType) -> ())?
    
    var filteredActivities: [FitnessActivityType] {
        guard !searchText.isEmpty else { return FitnessActivityType.allCases }
        return FitnessActivityType.allCases.filter {
            $0.rawValue.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("What are you doing?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("Select an activity to get started")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 20)
            
            // ── Search ─────────────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
                
                TextField("Search activities...", text: $searchText)
                    .font(.system(size: 15))
                    .focused($searchFocused)
                    .autocorrectionDisabled()
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            // ── Activity grid ──────────────────────────────────────────
            if filteredActivities.isEmpty {
                emptySearch
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredActivities) { activity in
                            activityCard(activity)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Fitness")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Activity Card
    
    @ViewBuilder
    private func activityCard(_ activity: FitnessActivityType) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedActivity = activity
            }
            // Small delay so the selection animation is visible
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                activitySelected?(activity)
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(activity.color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: activity.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(activity.color)
                }
                
                Text(activity.rawValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                selectedActivity == activity
                    ? activity.color.opacity(0.12)
                    : Color(UIColor.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        selectedActivity == activity
                            ? activity.color
                            : Color(UIColor.separator),
                        lineWidth: selectedActivity == activity ? 2 : 0.5
                    )
            }
            .scaleEffect(selectedActivity == activity ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: selectedActivity)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Empty Search
    
    private var emptySearch: some View {
        VStack(spacing: 12) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 64, height: 64)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            
            Text("No results for \"\(searchText)\"")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            Text("Try a different search or pick Other")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.secondary)
            
            Button {
                searchText = ""
                activitySelected?(.other)
            } label: {
                Text("Use Other")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    FitnessActivityPickerView()
}
