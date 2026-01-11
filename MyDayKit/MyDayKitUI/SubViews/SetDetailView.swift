//
//  SetDetailView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct SetDetailView: View {
    
    @State private var isShowing: Bool = false
    @State private var isShowingDelete: Bool = false
    
    let model: ExerciseCompletions
    let animation: Namespace.ID
    let isToday: Bool
    var close: (() -> ())?
    var edit: (() -> ())?
    var delete: (() -> ())?
    
    var body: some View {
        VStack {
            if isShowing {
                if isShowingDelete {
                    Text(model.exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .transition(.scale(scale: 1.1))
                    
                    Text(formattedTime(from: model.dateCompleted))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.5))
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowing = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            close?()
                        }
                    } label: {
                        Text("Close")
                    }
                    Spacer()
                    Text("Are you sure you want to delete this completion? This action cannot be undone.")
                        .multilineTextAlignment(.center)
                    Spacer()
                    HStack {
                        Button {
                            isShowingDelete = false
                        } label: {
                            Text("Cancel")
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color
                                        .blue
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                        }
                        
                        Button {
                            delete?()
                        } label: {
                            Text("Delete")
                                .foregroundStyle(Color.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background {
                                    Color
                                        .red
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                        }
                    }
                    .transition(.opacity)
                } else {
                    Text(model.exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.primary)
                        .transition(.scale(scale: 1.1))
                    
                    Text(formattedTime(from: model.dateCompleted))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.5))
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isShowing = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            close?()
                        }
                    } label: {
                        Text("Close")
                    }
                    
                    Text("\(model.reps)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.black)
                    
                    HStack {
                        VStack {
                            Text("reps")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .center)
                            Text("\(model.reps)")
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        }
                        
                        VStack {
                            Text("weight")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .center)
                            HStack(spacing: 0) {
                                if model.weight != nil || model.weightUnit != nil {
                                    if let weight = model.weight {
                                        Text("\(weight.formatted(.number.precision(.fractionLength(0...6))))")
                                    }
                                    if let weightUnit = model.weightUnit {
                                        Text("\(weightUnit.rawValue)")
                                    } else {
                                        Text("-")
                                    }
                                } else {
                                    Text("-")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        }
                    }
                    .transition(.opacity)
                    
                    HStack {
                        VStack {
                            Text("distance")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .center)
                            if model.distance != nil || model.distanceUnits != nil {
                                HStack(spacing: 0) {
                                    if let distance = model.distance {
                                        Text("\(distance.formatted(.number.precision(.fractionLength(0...6))))")
                                    }
                                    if let distanceUnit = model.distanceUnits {
                                        Text("\(distanceUnit.rawValue)")
                                    } else {
                                        Text("-")
                                    }
                                }
                            } else {
                                Text("-")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        }
                        
                        VStack {
                            Text("time")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .center)
                            if let time = model.time {
                                HStack {
                                    Text(displayTime(for: time))
                                }
                            } else {
                                Text("-")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        }
                    }
                    .transition(.opacity)

                    
                    VStack {
                        if let tempo = model.tempo {
                            Text("tempo")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("\(tempo.eccentric)-\(tempo.eccentricHold)-\(tempo.concentric)-\(tempo.concentricHold)")
                        } else {
                            Text("-")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background {
                        Color
                            .white
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(radius: 4)
                    }
                    .transition(.opacity)
                    
                    
                    if let note = model.note {
                        VStack {
                            Text("note")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.black.opacity(0.5))
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(note)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background {
                            Color
                                .white
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .shadow(radius: 4)
                        }
                    }
                    
                    Spacer()
                    
                    if isToday {
                        HStack {
                            Button {
                                edit?()
                            } label: {
                                Text("Edit")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        Color
                                            .blue
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                            }
                            
                            Button {
                                isShowingDelete = true
                            } label: {
                                Text("Delete")
                                    .foregroundStyle(Color.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background {
                                        Color
                                            .red
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                            }
                        }
                        .transition(.opacity)
                    }
                }
            } else {
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .matchedGeometryEffect(id: "\(model.id)background", in: animation)
                .foregroundStyle(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(Color.black, lineWidth: 1)
                        .matchedGeometryEffect(id: "\(model.id)overlay", in: animation)
                }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowing = true
                }
            }
        }
    }
    
    func formattedTime(from date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "HH:mm" // 24-hour format
         return formatter.string(from: date)
     }
    
    func displayTime(for totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

#Preview {
    @Previewable @Namespace var namespace
    SetDetailView(
        model: .init(
            id: "",
            exercise: .pressUps,
            reps: 10,
            weight: 10,
            weightUnit: .kg,
            dateCompleted: .now,
            distance: 50,
            distanceUnits: .metres,
            time: 45,
            tempo: Tempo(),
            note: "This is s test note",
            eachSide: false
        ),
        animation: namespace,
        isToday: true
    )
    .padding()
}
