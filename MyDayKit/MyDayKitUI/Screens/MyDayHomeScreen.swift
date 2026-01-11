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
    // Generate past 30 days including today
    let dates: [Date] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (-3..<30).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed() // So the most recent dates (today) are on the right
    }()
    
    @State private var dateDropDown: Bool = false
    @State private var selectedSet: ExerciseCompletions?
    @State private var selectedActivity: MyDayActivity = .exercises
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E\nd" // E = day of week, d = day number
        return formatter
    }()
    
    let dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E - d" // E = day of week, d = day number
        return formatter
    }()
    
    @ObservedObject var dayManager: MyDayManager
    
    var addButtonAction: (() -> ())?
    var addSpecificExercise: ((MyDayNewExerciseManager) -> ())?
    var recordClip: (() -> ())?
    var edit: ((MyDayNewExerciseManager) -> ())?
    
    var body: some View {
        
        VStack {
            HStack(alignment: .firstTextBaseline) {
                
                Text("MYDAY")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    addButtonAction?()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .disabled(!dayManager.isTodaySelected())
                .opacity(dayManager.isTodaySelected() ? 1 : 0.3)
            }
            .padding()
            
            if let dayModel = dayManager.selectedDay {
                Button {
                    withAnimation {
                        dateDropDown.toggle()
                    }
                } label: {
                    let isToday = calendar.isDateInToday(dayModel.date)
                    
                    Text(isToday ? "Today" : dateFormatter2.string(from: dayModel.date))
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .background {
                            Color(.systemGray6)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading)
            }
            if dateDropDown {
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(dates, id: \.self) { date in
                                let isSelected = dayManager.isDaySelected(date)
                                let isToday = calendar.isDateInToday(date)
                                let isFuture = date > Date()
                                
                                Text(isToday ? "Today" : formattedDate(date))
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(isSelected ? .white : .primary)
                                    .frame(width: 44, height: 60)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(isSelected ? Color.blue : Color(.systemGray6))
                                    )
                                    .opacity(isFuture ? 0.3 : 1.0)
                                    .onTapGesture {
                                        guard !isFuture else { return }
                                        dayManager.changeSelectedDay(to: date)
                                        withAnimation {
                                            proxy.scrollTo(date, anchor: .center)
                                        }
                                    }
                                    .id(date)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .task {
                        // Scroll to today
                        if let today = dates.last {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                proxy.scrollTo(today, anchor: .trailing)
                            }
                        }
                    }
                }
            }
            
            HStack {
                ForEach(MyDayActivity.allCases, id: \.self) { activity in
                    Button {
                        selectedActivity = activity
                    } label: {
                        VStack {
                            Text(activity.title)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.primary.opacity(selectedActivity == activity ? 1 : 0.4))
                            if activity == selectedActivity {
                                RoundedRectangle(cornerRadius: 4)
                                    .matchedGeometryEffect(id: "activityUnderline", in: animation)
                                    .frame(height: 2)
                                    .foregroundStyle(Color.blue)
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .frame(height: 2)
                                    .foregroundStyle(Color.clear)
                            }
                        }
                    }
                }
            }
            .animation(.easeIn, value: selectedActivity)
            
            if let selectedDay = dayManager.selectedDay {
                if selectedDay.exercises.isEmpty {
                    if dayManager.isTodaySelected() {
                        VStack {
                            Spacer()
                            Text("Record todays exercises")
                            Button {
                                addButtonAction?()
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                            Spacer()
                        }
                    } else {
                        VStack {
                            Spacer()
                            Text("No exercises recorded on this day")
                            Spacer()
                        }
                    }
                } else {
                    List {
                        ForEach(selectedDay.exercises) { exercise in
                            Section {
                                ExerciseCompletionView(
                                    model: exercise,
                                    selected: selectedSet,
                                    disabled: !dayManager.isTodaySelected(),
                                    animation: animation,
                                    addAction: {
                                        let newExercise = MyDayNewExerciseManager(exercise: exercise.exercise)
                                        addSpecificExercise?(newExercise)
                                    },
                                    addClipButtonAction: {
                                        recordClip?()
                                    },
                                    repeatSet: { model in
                                        dayManager.addNewCompletion(model)
                                    },
                                    onTap: { model in
                                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                                            selectedSet = model
                                        }
                                    }
                                )
                                .listRowInsets(EdgeInsets())
                            }
                        }
                    }
                }
            } else {
                Text("loading...")
            }
        }
        .overlay {
            if let selectedSet {
                Color
                    .black
                    .opacity(0.7)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                SetDetailView(
                    model: selectedSet,
                    animation: animation,
                    isToday: dayManager.isTodaySelected(),
                    close: {
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.selectedSet = nil
                        }
                    },
                    edit: {
                        let new = MyDayNewExerciseManager(
                            exercise: selectedSet.exercise,
                            reps: selectedSet.reps,
                            weight: selectedSet.weight,
                            weightUnits: selectedSet.weightUnit,
                            distance: selectedSet.distance,
                            distanceUnits: selectedSet.distanceUnits,
                            time: selectedSet.time,
                            tempo: selectedSet.tempo,
                            note: selectedSet.note,
                            eachSide: selectedSet.eachSide
                        )
                        new.editingCompletion = selectedSet
                        edit?(new)
                        self.selectedSet = nil
                    },
                    delete: {
                        dayManager.deleteCompletion(selectedSet)
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.selectedSet = nil
                        }
                    }
                )
                .transition(.asymmetric(insertion: .identity, removal: .offset(y: 5)))
                .padding()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

#Preview {
    MyDayHomeScreen(
        dayManager: MyDayManager(
            saver: PreviewSaver(),
            deleteSaver: PreviewMyDaySaver(),
            loader: PreviewLoader(),
            deleter: PreviewMyDayDeleter()
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
