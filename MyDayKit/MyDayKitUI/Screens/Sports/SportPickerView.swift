//
//  SportPickerView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/03/2026.
//

import SwiftUI

struct SportPickerView: View {
    
    @State private var searchText: String = ""
    @State private var selectedCategory: SportCategory?
    @FocusState private var searchFocused: Bool
    
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var sportSelected: ((SportType) -> ())?
    
    var filteredSports: [SportType] {
        var sports = SportType.allCases
        if let category = selectedCategory {
            sports = sports.filter { $0.category == category }
        }
        if !searchText.isEmpty {
            sports = sports.filter {
                $0.rawValue.lowercased().contains(searchText.lowercased())
            }
        }
        return sports
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            VStack(spacing: 6) {
                Text("Select Sport")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text("What sport are you logging?")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // ── Search ─────────────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
                
                TextField("Search sports...", text: $searchText)
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
            .padding(.bottom, 12)
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            // ── Category filter ────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    categoryChip(nil, label: "All")
                    ForEach(SportCategory.allCases, id: \.self) { category in
                        categoryChip(category, label: category.rawValue)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            // ── Sport grid ─────────────────────────────────────────────
            if filteredSports.isEmpty {
                emptySearch
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredSports) { sport in
                            sportCard(sport)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationTitle("Sport")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Category Chip
    
    @ViewBuilder
    private func categoryChip(_ category: SportCategory?, label: String) -> some View {
        let isSelected = selectedCategory == category
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedCategory = category
            }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(isSelected ? Color.blue : Color(UIColor.secondarySystemBackground))
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .stroke(
                            isSelected ? Color.clear : Color(UIColor.separator),
                            lineWidth: 0.5
                        )
                }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Sport Card
    
    @ViewBuilder
    private func sportCard(_ sport: SportType) -> some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                sportSelected?(sport)
            }
        } label: {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(sport.color.opacity(0.12))
                        .frame(width: 56, height: 56)
                    Image(systemName: sport.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(sport.color)
                }
                
                Text(sport.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(UIColor.separator), lineWidth: 0.5)
            }
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
            Text("Try a different search or select Other")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.secondary)
            Button {
                searchText = ""
                sportSelected?(.other)
            } label: {
                Text("Use Other")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    SportPickerView()
}
