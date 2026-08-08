//
//  MyDayWorkoutCreationHomeScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/04/2026.
//

import SwiftUI

struct MyDayWorkoutCreationHomeScreen: View {
    
    @ObservedObject var manager: WorkoutBuilderManager
    @FocusState private var isFocused: Bool
    
    private var titleSuggestions: [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let day = formatter.string(from: Date())
        return [
            "\(day) Upper",
            "\(day) Lower",
            "\(day) Full Body",
            "\(day) Strength",
            "\(day) Recovery",
            "\(day) Cardio",
            "\(day) Mixed",
            "\(day) Push",
            "\(day) Pull",
            "\(day) Legs",
        ]
    }
    
    private var showSuggestions: Bool {
        manager.title.isEmpty || isFocused
    }
    
    private var canUpload: Bool {
        !manager.title.isEmpty && !manager.exercises.isEmpty
    }

    private var isUploading: Bool {
        if case .uploading = manager.uploadState { return true }
        return false
    }
    
    var onOptionsTapped: (() -> ())?
    var addExerciseTapped: (() -> ())?
    var uploadComplete: (() -> ())?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                
                // MARK: - Title TextField
                VStack(alignment: .leading, spacing: 8) {
                    Text("Workout Title")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Workout title...", text: $manager.title)
                            .focused($isFocused)
                            .font(.system(size: 17, weight: .medium))
                            .submitLabel(.done)
                        
                        if !manager.title.isEmpty {
                            Button {
                                manager.title = ""
                                isFocused = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.darkColor)
                                    .font(.system(size: 18))
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(
                                        isFocused ? Color.darkColor.opacity(0.6) : Color.clear,
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: manager.title.isEmpty)
                    .animation(.easeInOut(duration: 0.15), value: isFocused)
                    
                    // MARK: - Suggestions
                    if showSuggestions {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(titleSuggestions, id: \.self) { suggestion in
                                    Button {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            manager.title = suggestion
                                            isFocused = false
                                        }
                                    } label: {
                                        Text(suggestion)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(.darkColor)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(
                                                Capsule()
                                                    .fill(Color.darkColor.opacity(0.1))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal, -20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 20)
                
                // MARK: - Exercises Label
                HStack {
                    Text("Exercises")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(1.2)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // MARK: - Exercises Section
                ZStack(alignment: .bottomTrailing) {
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.darkColor.opacity(0.3))
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    
                    if manager.exercises.isEmpty {
                        
                        // MARK: Empty State
                        VStack(spacing: 16) {
                            Image(systemName: "dumbbell")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.tertiary)
                            
                            VStack(spacing: 4) {
                                Text("No Exercises Yet")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text("Add exercises to build your workout")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button {
                                addExerciseTapped?()
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                    Text("Add Exercise")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.darkColor)
                                )
                                .foregroundColor(.white)
                            }
                            .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        
                    } else {
                        
                        // MARK: Exercise List
                        ScrollViewReader { proxy in
                            List {
                                ForEach(manager.exercises, id: \.self) { exercise in
                                    HStack(spacing: 12) {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .fill(Color.darkColor.opacity(0.12))
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Image(systemName: "dumbbell.fill")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(Color.darkColor)
                                            )
                                        
                                        Text(exercise.exercise.name)
                                            .font(.system(size: 16, weight: .medium))
                                        
                                        Spacer()
                                        
                                        Image(systemName: "line.3.horizontal")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(.vertical, 4)
                                    .listRowBackground(Color(.secondarySystemBackground))
                                }
                                .onDelete { indexSet in
                                    withAnimation {
                                        manager.exercises.remove(atOffsets: indexSet)
                                    }
                                }
                                
                                Color.clear
                                    .frame(height: 72)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .id("bottomSpacer")
                            }
                            .listStyle(.plain)
                            .scrollContentBackground(.hidden)
                            .listSectionSpacing(0)
                            .contentMargins(.top, 0, for: .scrollContent)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .onChange(of: manager.exercises.count) { _, _ in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    proxy.scrollTo("bottomSpacer", anchor: .bottom)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }
                        // MARK: Floating Add Button
                        Button {
                            addExerciseTapped?()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(Color.darkColor)
                                        .shadow(color: Color.darkColor.opacity(0.4), radius: 12, x: 0, y: 6)
                                )
                        }
                        .padding()
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: manager.exercises.isEmpty)
                
                // MARK: - Upload Button
                Button {
                    Task {
                        await manager.uploadWorkout()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Upload")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(canUpload ? Color.darkColor : Color(.tertiarySystemFill))
                    )
                    .foregroundColor(canUpload ? .white : .secondary)
                }
                .disabled(!canUpload || isUploading)
                .animation(.easeInOut(duration: 0.2), value: canUpload)
                .padding()
            }
            .navigationTitle("Create Workout")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onOptionsTapped?()
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            
            // MARK: - Uploading Overlay
            if isUploading {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.3)
                        
                        Text("Uploading Workout…")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(36)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                }
                .transition(.opacity)
            }
        }
        .onChange(of: manager.uploadState) { _, newState in
            if case .success = newState {
                uploadComplete?()
            }
        }
    }
}

#Preview {
    MyDayWorkoutCreationHomeScreen(
        manager: WorkoutBuilderManager(
            uploader: PreviewWorkoutTemplateUploading()
        )
    )
}
