//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 24/04/2023.
//

import SwiftUI

struct UnitsSelectionView: View {
    
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    @State private var selectedUnit: Units?
    
    var body: some View {
        VStack {
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top) {
                        ForEach(viewModel.setModels) { model in
                            SetView(model: model, isSelected: viewModel.selectedSetModel == model) {
                                viewModel.toggleSetSelected(model)
                                withAnimation {
                                    value.scrollTo(model.setNumber)
                                }
                            }
                            .id(model.setNumber)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            ZStack {
                
            }
            
            if let selectedUnit {
                switch selectedUnit {
                case .weight:
                    WeightSelectionSheet(viewModel: viewModel, selectedUnit: $selectedUnit)
                case .distance:
                    DistanceSelectionSheet(viewModel: viewModel, selectedUnit: $selectedUnit)
                case .time:
                    TimeSelectionSheet(viewModel: viewModel, selectedUnit: $selectedUnit)
                case .restime:
                    RestTimeSelectionSheet(viewModel: viewModel, selectedUnit: $selectedUnit)
                case .tempo:
                    TempoSelectionSheet(viewModel: viewModel, selectedUnit: $selectedUnit)
                }
                Spacer()
                Button {
                    viewModel.clearAll(selectedUnit)
                } label: {
                    Text("Clear All \(selectedUnit.title)s")
                        .font(.footnote.bold())
                        .foregroundColor(.red)
                }
            } else {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2)) {
                    ForEach(Units.allCases, id:\.title) { unit in
                        Button {
                            selectedUnit = unit
                        } label: {
                            Text(unit.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.lightColour))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            
            Spacer()
        }
    }
}

struct UnitsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        UnitsSelectionView(viewModel: ExerciseCreationHomeViewModel(workoutCreation: PreviewWorkoutCreation()))
    }
}


struct SetView: View {
    
    var model: SetModel
    
    var isSelected: Bool
    
    var action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text("Set \(model.setNumber + 1)")
                Text("\(model.reps) Reps")
                if let weight = model.weight {
                    switch weight.unit {
                    case .max, .bodyweight:
                        Text(weight.unit.title)
                    case .kilograms, .pounds, .maxPercentage, .bodyweightPercentage:
                        if let value = weight.value {
                            if value == floor(value) {
                                Text("\(Int(value))\(weight.unit.title)")
                            } else {
                                Text("\(value, specifier: "%.2f") \(weight.unit.title)")
                            }
                        }
                    }
                }
                if let distance = model.distance {
                    Text("\(distance.value, specifier: "%.2f")\(distance.unit.title)")
                }
                if let time = model.time {
                    Text("\(time.value, specifier: "%.0f")\(time.unit.title)")
                }
                if let restTime = model.restTime {
                    Text("\(restTime.value, specifier: "%.0f")\(restTime.unit.title)")
                }
                if let tempo = model.tempo {
                    Text("\(tempo.eccentric)-\(tempo.eccentricHold)-\(tempo.concentric)-\(tempo.concentricHold)")
                }
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .background(isSelected ? Color(.darkColour) : Color(.lightColour))
            .cornerRadius(8)
            .id(model.setNumber)
        }
    }
}
