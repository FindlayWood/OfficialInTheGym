//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 01/05/2023.
//

import SwiftUI

struct EmptySetView: View {
    
    var model: SetModel
    
    var body: some View {
        VStack {
            Text("Set \(model.setNumber + 1)")
                .font(.title3.bold())
            Text("\(model.reps)  reps")
                .font(.title3.bold())
            if let weight = model.weight {
                if let value = weight.value {
                    Text("\(value, specifier: "%.2f")\(weight.unit.title)")
                        .font(.headline)
                } else {
                    Text(weight.unit.title)
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
        }
        .foregroundColor(.white)
        .padding()
        .background(model.completed ? Color(.darkColour) : Color(.lightColour))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        EmptySetView(model: .example)
    }
}
