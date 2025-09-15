//
//  MyDayHomeScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 26/07/2025.
//

import SwiftUI

struct MyDayHomeScreen: View {
    
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
//                                withAnimation {
                                    proxy.scrollTo(today, anchor: .trailing)
//                                }
                            }
                        }
                    }
                }
            }
            
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
                                TakeView(
                                    model: exercise,
                                    disabled: !dayManager.isTodaySelected(),
                                    addAction: {
                                        let newExercise = MyDayNewExerciseManager(exercise: exercise.exercise)
                                        addSpecificExercise?(newExercise)
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
    }
    
    private func formattedDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
}

#Preview {
    MyDayHomeScreen(dayManager: MyDayManager())
}

import SwiftUI

struct ProgressRingView: View {
    let current: Int
    let goal: Int
    let lineWidth: CGFloat
    let ringColor: Color
    let backgroundColor: Color

    private var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(current) / Double(goal), 1.0)
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress Circle
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(
                    ringColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from top

            // Center Text
            Text("\(current)/\(goal)")
                .font(.system(size: 16, weight: .semibold))
        }
        .frame(width: 50, height: 50)
    }
}


struct TakeView: View {
    
    @ObservedObject var model: MyDayExerciseModel
    
    let disabled: Bool
    
    var addAction: (() -> ())?
    var addClipButtonAction: (() -> ())?
    
    var body: some View {
        VStack {
            HStack {
                Text(model.exercise.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.primary)
                Spacer()
                Button {
                    addAction?()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .disabled(disabled)
                .opacity(disabled ? 0.3 : 1)
            }
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(model.completions) { completion in
                            VStack {
                                Text("\(completion.reps)")
                                if let weight = completion.weight, let unit = completion.weightUnit {
                                    Text("\(weight) \(unit.rawValue)")
                                }
                            }
                            .padding()
                            .background {
                                Color.white
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .shadow(radius: 2)
                            }
                            
                            
                        }
                    }
                    .padding()
                }
            }
            
            VStack {
                Button {
                    addClipButtonAction?()
                } label: {
                    Text("Add Clip")
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .padding()
        .background {
            Color
                .white
                .shadow(radius: 4)
        }
    }
}
