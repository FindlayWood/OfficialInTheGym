//
//  MyDayExerciseListView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 28/07/2025.
//

import SwiftUI

struct MyDayExerciseListView: View {
    
    @State private var selectedCategory: ExerciseCategory = .upperBody
    @State private var searchText: String = ""
    @FocusState private var searchFocused: Bool
    
    @ObservedObject var exerciseManager: ExerciseManager
    
    var selectedExercise: ((MyDayNewExerciseManager) -> ())?
    var selectedWorkoutExercise: ((Exercise) -> ())?
    
    var filteredExercises: [Exercise] {
        let base = exerciseManager.exercises
            .filter { $0.category == selectedCategory }
            .sorted { $0.name < $1.name }
        
        guard !searchText.isEmpty else { return base }
        
        return base.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Category filter ────────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(ExerciseCategory.allCases, id: \.self) { cat in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = cat
                            }
                        } label: {
                            Text(cat.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(
                                    selectedCategory == cat
                                        ? Color.white
                                        : Color.primary
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    selectedCategory == cat
                                        ? Color.blue
                                        : Color(UIColor.secondarySystemBackground)
                                )
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(
                                            selectedCategory == cat
                                                ? Color.clear
                                                : Color(UIColor.separator),
                                            lineWidth: 0.5
                                        )
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            
            Divider()
            
            // ── Search bar ─────────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.secondary)
                
                TextField("Search exercises...", text: $searchText)
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
            .padding(.vertical, 10)
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            Divider()
            
            // ── Content ────────────────────────────────────────────────
            if exerciseManager.isLoading {
                loadingView
            } else if filteredExercises.isEmpty {
                emptyView
            } else {
                exerciseList
            }
        }
        .navigationTitle("Select Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await exerciseManager.load()
        }
    }
    
    // MARK: - Exercise List
    
    private var exerciseList: some View {
        List {
            ForEach(filteredExercises, id: \.name) { exercise in
                Button {
                    let newExercise = MyDayNewExerciseManager(exercise: exercise)
                    selectedExercise?(newExercise)
                    selectedWorkoutExercise?(exercise)
                } label: {
                    HStack(spacing: 12) {
                        // Category colour dot
                        Circle()
                            .fill(selectedCategory.color.opacity(0.8))
                            .frame(width: 8, height: 8)
                        
                        Text(exercise.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                    }
                    .padding(.vertical, 2)
                }
                .listRowBackground(Color(UIColor.systemBackground))
            }
        }
        .listStyle(.plain)
    }
    
    // MARK: - Loading
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.1)
            Text("Loading exercises...")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.secondary)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyView: some View {
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
            
            Text(searchText.isEmpty ? "No exercises found" : "No results for \"\(searchText)\"")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.primary)
            
            Text(searchText.isEmpty
                 ? "Try selecting a different category"
                 : "Check the spelling or try a different search"
            )
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.secondary)
                .multilineTextAlignment(.center)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Text("Clear search")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
    }
}

#Preview {
    MyDayExerciseListView(exerciseManager: ExerciseManager(loader: PreviewExerciseLoader()))
}
