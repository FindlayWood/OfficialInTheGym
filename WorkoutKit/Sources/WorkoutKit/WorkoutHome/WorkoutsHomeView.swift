//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import SwiftUI

struct WorkoutsHomeView: View {
    
    @ObservedObject var viewModel: WorkoutsHomeViewModel
    
    @State private var selectedOption: WorkoutOption = .all
    
    @Namespace var namespace
    
    enum WorkoutOption: String, CaseIterable, Identifiable {
        case all
        case notStarted
        case completed
        
        var id: String {
            self.rawValue
        }
        
        var title: String {
            switch self {
            case .all:
                return "All"
            case .notStarted:
                return "Not Started"
            case .completed:
                return "Completed"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("MYWORKOUTS")
                    .font(.title.bold())
                    .foregroundColor(Color(.darkColour))
                Spacer()
                Button {
                    viewModel.addAction()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(.darkColour))
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            HStack {
                ForEach(WorkoutOption.allCases) { option in
                    VStack {
                        Text(option.title)
                            .font(option == selectedOption ? .headline : .body)
                            .foregroundColor(option == selectedOption ? Color(.darkColour) : .secondary)
                        if option == selectedOption {
                            Rectangle()
                                .foregroundColor(Color(.darkColour))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                                .matchedGeometryEffect(id: "line", in: namespace)
                        } else {
                            Rectangle()
                                .foregroundColor(Color(.clear))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedOption = option
                        }
                    }
                }
            }
            .padding(.top)
            if viewModel.workouts.isEmpty {
                VStack {
                    ZStack {
                        Image(systemName: "dumbbell.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color(.darkColour))
                        Image(systemName: "nosign")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.red.opacity(0.5))
                    }
                    Text("No Workouts")
                        .font(.title.bold())
                        .foregroundColor(Color(.darkColour))
                    Text("You have no workouts in your list. You can add workouts from your Saved Workout List or by creating a new workout. Once you have added workouts to your list they will appear here.")
                        .font(.footnote.bold())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Button {
                        viewModel.addAction()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(.darkColour).opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.secondarySystemBackground))
            } else {
                SearchBar(searchText: $viewModel.searchText, placeholder: "search workouts...")
                List {
                    ForEach(viewModel.filteredResults) { model in
                        Section {
                            Button {
                                viewModel.showWorkoutAction(model)
                            } label: {
                                WorkoutRow(model: model)   
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

struct WorkoutsHomeView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutsHomeView(viewModel: WorkoutsHomeViewModel())
    }
}

struct WorkoutRow: View {
    var model: WorkoutCardModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text(model.workout.title)
                .font(.title2.bold())
                .foregroundColor(Color(.darkColour))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
            Rectangle()
                .fill(.black)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
            HStack {
                if model.workout.completed {
                    Text("COMPLETED")
                        .font(.callout.bold())
                        .foregroundColor(Color(.completedColour))
                    if let date = model.workout.startDate {
                        Text(date, format: .dateTime.day().month().year())
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                } else if model.workout.liveWorkout ?? false {
                    Text("LIVE")
                        .font(.callout)
                        .foregroundColor(Color(.liveColour))
                        .fontWeight(.semibold)
                } else if model.workout.startDate != nil {
                    Text("IN PROGRESS")
                        .font(.callout)
                        .foregroundColor(Color(.liveColour))
                        .fontWeight(.semibold)
                } else {
                    Text("NOT STARTED")
                        .font(.callout)
                        .foregroundColor(Color(.notStartedColour))
                        .fontWeight(.semibold)
                }
            }
            .padding(.top, 8)
            WorkoutFiguresView(model: model)
                .padding(.top)
//            if let clipData = model.clipData {
//                if clipData.count > 0 {
//                    WorkoutClipThumbnailView(models: clipData)
//                }
//            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 1)
        )
    }
}

struct WorkoutFiguresView: View {
    var model: WorkoutCardModel
    var body: some View {
        HStack(spacing: 16) {
            VStack {
                Text(model.exercises.count, format: .number)
                    .font(.body.bold())
                    .foregroundColor(.primary)
                Text("Exercises")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            if model.workout.completed == true {
                if let time = model.workout.secondsToComplete {
                    VStack {
                        Text(time, format: .number)
                            .font(.body.bold())
                            .foregroundColor(.primary)
                        Text("Duration")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                    }
                }
                if let rpe = model.workout.rpe {
                    VStack {
                        Text(rpe, format: .number)
                            .font(.body.bold())
                            .foregroundColor(.primary)
                        Text("RPE")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.secondary)
                        
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(.secondarySystemBackground))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(placeholder, text: $searchText)
                    .foregroundColor(.primary)
                    .tint(Color(.darkColour))
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}
