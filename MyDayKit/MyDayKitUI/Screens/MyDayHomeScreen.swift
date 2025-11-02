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
    var recordClip: (() -> ())?
    
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
                                    },
                                    addClipButtonAction: {
                                        recordClip?()
                                    },
                                    repeatSet: { model in
                                        dayManager.addNewCompletion(model)
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
    MyDayHomeScreen(dayManager: MyDayManager(saver: PreviewSaver(), loader: PreviewLoader()))
}
