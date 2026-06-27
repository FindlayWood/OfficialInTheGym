//
//  MyDayHomeScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 26/07/2025.
//

import SwiftUI

struct MyDayHomeScreen: View {
    
    @Namespace var animation
    
    let calendar = Calendar.current
    let dates: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (-3..<30).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()
    }()
    
    @State private var dateDropDown: Bool = false
    @State private var selectedSet: ExerciseCompletions?
    @State private var selectedClip: MyDayClipModel?
    @State private var selectedActivity: MyDayActivity = .exercises
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E\nd"
        return formatter
    }()
    
    let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E - d"
        return formatter
    }()
    
    @ObservedObject var dayManager: MyDayManager
    
    var addButtonAction: (() -> ())?
    var addSpecificExercise: ((MyDayNewExerciseManager) -> ())?
    var recordClip: ((String) -> ())?
    var edit: ((MyDayNewExerciseManager) -> ())?
    var clipSelected: ((MyDayClipModel, UIImage, CGRect) -> ())?
    
    private var isToday: Bool { dayManager.isTodaySelected() }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Header ─────────────────────────────────────────────────
            header
            
            Divider()
            
            // ── Activity tabs ──────────────────────────────────────────
//            activityTabs
//            
//            Divider()
            
            // ── Content ────────────────────────────────────────────────
            if let selectedDay = dayManager.selectedDay {
                if selectedDay.exercises.isEmpty && selectedDay.workouts.isEmpty {
                    emptyState
                } else {
                    exerciseList(for: selectedDay)
                }
            } else {
                loadingView
            }
        }
        .background {
            Color.darkColor.ignoresSafeArea()
        }
        .overlay {
            if let selectedSet {
                setDetailOverlay(for: selectedSet)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("MyDay")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.darkColor)
                    
                    // Date selector trigger
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            dateDropDown.toggle()
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if let dayModel = dayManager.selectedDay {
                                Text(calendar.isDateInToday(dayModel.date)
                                     ? "Today"
                                     : dateFormatter2.string(from: dayModel.date))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                            }
                            Image(systemName: dateDropDown ? "chevron.up" : "chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                if isToday {
                    Button {
                        addButtonAction?()
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "plus")
                                .font(.system(size: 13, weight: .bold))
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // ── Date strip ─────────────────────────────────────────────
            if dateDropDown {
                dateStrip
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background {
            Color.white.ignoresSafeArea()
        }
    }
    
    // MARK: - Date Strip
    
    private var dateStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dates, id: \.self) { date in
                        let isSelected = dayManager.isDaySelected(date)
                        let isToday = calendar.isDateInToday(date)
                        let isFuture = date > Date()
                        
                        VStack(spacing: 3) {
                            Text(isToday ? "Today" : formattedDateDay(date))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(isSelected ? Color.white.opacity(0.8) : Color.secondary)
                            
                            Text(formattedDateNumber(date))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(isSelected ? Color.white : Color.primary)
                        }
                        .frame(width: 44, height: 56)
                        .background(
                            isSelected
                                ? Color.blue
                                : Color(UIColor.secondarySystemBackground)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    isSelected ? Color.clear : Color(UIColor.separator),
                                    lineWidth: 0.5
                                )
                        }
                        .opacity(isFuture ? 0.3 : 1.0)
                        .onTapGesture {
                            guard !isFuture else { return }
                            withAnimation(.easeInOut(duration: 0.2)) {
                                dayManager.changeSelectedDay(to: date)
                                proxy.scrollTo(date, anchor: .center)
                            }
                        }
                        .id(date)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
            .task {
                if let today = dates.last {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        proxy.scrollTo(today, anchor: .trailing)
                    }
                }
            }
        }
    }
    
    // MARK: - Activity Tabs
    
    private var activityTabs: some View {
        HStack(spacing: 0) {
            ForEach(MyDayActivity.allCases, id: \.self) { activity in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedActivity = activity
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(activity.title)
                            .font(.system(size: 14, weight: selectedActivity == activity ? .semibold : .regular))
                            .foregroundStyle(
                                selectedActivity == activity
                                    ? Color.primary
                                    : Color.secondary
                            )
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.clear)
                                .frame(height: 2)
                            
                            if activity == selectedActivity {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.blue)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "activityUnderline", in: animation)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Exercise List
    
    private func exerciseList(for day: MyDayFullDayModel) -> some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 12) {
                WellnessSummaryCard(
                    viewModel: WellnessQuestionnaireViewModel(
                        existingEntry: day.wellnessEntry,
                        onComplete: { entry in
                            dayManager.saveWellnessEntry(entry)
                        }
                    ),
                    isCurrentDay: isToday
                )
     
                // MARK: - Workout Cards
                if !day.workouts.isEmpty {
                    HStack {
                        Text("Workouts")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.2)
                        Spacer()
                    }
     
                    ForEach(day.workouts) { entry in
                        DailyWorkoutCard(entry: entry) {
//                            workoutEntryTapped?(entry)
                        }
                    }
                }
     
                // MARK: - Individual Exercises
                if !day.exercises.isEmpty {
                    HStack {
                        Text("Exercises")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .tracking(1.2)
                        Spacer()
                    }
                }
     
                ForEach(day.exercises) { exercise in
                    ExerciseCompletionView(
                        model: exercise,
                        selected: selectedSet,
                        disabled: !isToday,
                        animation: animation,
                        addAction: {
                            let newExercise = MyDayNewExerciseManager(exercise: exercise.exercise)
                            addSpecificExercise?(newExercise)
                        },
                        addClipButtonAction: {
                            recordClip?(exercise.exercise.id)
                        },
                        repeatSet: { model in
                            dayManager.addNewCompletion(model)
                        },
                        onTap: { model in
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                selectedSet = model
                            }
                        },
                        clipSelected: clipSelected
                    )
                }
     
                if day.exercises.count > 0 {
                    RPECard(
                        entry: dayManager.selectedDay?.rpeEntry,
                        isCurrentDay: isToday,
                        onConfirm: { entry in
                            dayManager.saveRPEEntry(entry)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            
            WellnessSummaryCard(
                viewModel: WellnessQuestionnaireViewModel(
                    existingEntry: dayManager.selectedDay?.wellnessEntry,
                    onComplete: { entry in
                        dayManager.saveWellnessEntry(entry)
                    }
                ),
                isCurrentDay: isToday
            )
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color(UIColor.secondarySystemBackground))
                    .frame(width: 72, height: 72)
                Image(systemName: isToday ? "plus.circle" : "calendar.badge.minus")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Color.secondary)
            }
            
            VStack(spacing: 6) {
                Text(isToday ? "Nothing recorded yet" : "Rest day")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.primary)
                
                Text(isToday
                     ? "Start tracking your exercises, fitness or sport"
                     : "No activity was recorded on this day")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if isToday {
                Button {
                    addButtonAction?()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add Activity")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .clipShape(Capsule())
                }
            }
            
            Spacer()
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    // MARK: - Loading
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            Spacer()
            ProgressView()
                .scaleEffect(1.1)
            Text("Loading your day...")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.secondary)
            Spacer()
        }
    }
    
    // MARK: - Set Detail Overlay
    
    private func setDetailOverlay(for set: ExerciseCompletions) -> some View {
        ZStack {
            Color.black
                .opacity(0.6)
                .ignoresSafeArea()
                .transition(.opacity)
                .onTapGesture {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        selectedSet = nil
                    }
                }
            
            SetDetailView(
                model: set,
                animation: animation,
                isToday: isToday,
                close: {
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        selectedSet = nil
                    }
                },
                edit: {
                    let new = MyDayNewExerciseManager(
                        exercise: set.exercise,
                        reps: set.reps,
                        weight: set.weight,
                        weightUnits: set.weightUnit,
                        distance: set.distance,
                        distanceUnits: set.distanceUnits,
                        time: set.time,
                        tempo: set.tempo,
                        note: set.note,
                        eachSide: set.eachSide
                    )
                    new.editingCompletion = set
                    edit?(new)
                    selectedSet = nil
                },
                delete: {
                    dayManager.deleteCompletion(set)
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                        selectedSet = nil
                    }
                }
            )
            .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
            .padding()
        }
    }
    
    // MARK: - Helpers
    
    private func formattedDateDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    private func formattedDateNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

#Preview {
    MyDayHomeScreen(
        dayManager: MyDayManager(
            saver: PreviewSaver(),
            clipSaver: PreviewMyDaySaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter(),
            wellnessSaver: PreviewMyDaySaver(),
            rpeSaver: PreviewMyDaySaver(),
            workoutSaver: PreviewMyDaySaver()
        )
    )
}

enum MyDayActivity: CaseIterable {
    case exercises
    case fitness
    case sports
    
    var title: String {
        switch self {
        case .exercises:
            return "Exercises"
        case .fitness:
            return "Fitness"
        case .sports:
            return "Sports"
        }
    }
}
