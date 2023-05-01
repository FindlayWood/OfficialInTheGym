//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 01/05/2023.
//

import SwiftUI

struct WorkoutSetView: View {
    
    var model: SetModel
    
    let namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Text("Set \(model.setNumber + 1)")
                .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)set", in: namespace)
                .font(.title3.bold())
            Text("\(model.reps)  reps")
                .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)reps", in: namespace)
                .font(.title3.bold())
            if let weight = model.weight {
                if let value = weight.value {
                    Text("\(value, specifier: "%.2f")\(weight.unit.title)")
                        .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)fullweight", in: namespace)
                        .font(.headline)
                } else {
                    Text(weight.unit.title)
                        .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)shortweight", in: namespace)
                        .font(.headline)
                }
            } else {
                Text("0")
                    .font(.headline)
                    .opacity(0)
            }
            Button {
                
            } label: {
                Image(systemName: model.completed ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
            }
            .buttonStyle(.plain)
            .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)button", in: namespace)
        }
        .foregroundColor(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .matchedGeometryEffect(id: "\(model.id)\(model.setNumber)block", in: namespace)
                .foregroundColor(model.completed ? Color(.darkColour) : Color(.lightColour))
        )
        .shadow(radius: 4)
    }
}

struct WorkoutSetView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        WorkoutSetView(model: .example, namespace: namespace)
    }
}