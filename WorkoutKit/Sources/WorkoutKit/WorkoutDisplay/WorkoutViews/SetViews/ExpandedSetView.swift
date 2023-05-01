//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 01/05/2023.
//

import SwiftUI

struct ExpandedSetView: View {
    
    @Binding var selectedSet: SetModel?
    
    let namespace: Namespace.ID
    
    var body: some View {
        if let selectedSet {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                            self.selectedSet = nil
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                Text("Set \(selectedSet.setNumber + 1)")
                    .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)set", in: namespace)
                    .font(.title3.bold())
                Text("\(selectedSet.reps)  reps")
                    .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)reps", in: namespace)
                    .font(.title3.bold())
                if let weight = selectedSet.weight {
                    if let value = weight.value {
                        Text("\(value, specifier: "%.2f")\(weight.unit.title)")
                            .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)fullweight", in: namespace)
                            .font(.headline)
                    } else {
                        Text(weight.unit.title)
                            .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)shortweight", in: namespace)
                            .font(.headline)
                    }
                } else {
                    Text("0")
                        .font(.headline)
                        .opacity(0)
                }
                Spacer()
                Button {
                    
                } label: {
                    Image(systemName: selectedSet.completed ? "checkmark.circle.fill" : "circle")
                        .font(.headline)
                }
                .buttonStyle(.plain)
                .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)button", in: namespace)
            }
            .foregroundColor(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .matchedGeometryEffect(id: "\(selectedSet.id)\(selectedSet.setNumber)block", in: namespace)
                    .foregroundColor(selectedSet.completed ? Color(.darkColour) : Color(.lightColour))
            )
            .shadow(radius: 4)
            .padding()
            .padding(.vertical)
        }
    }
}

struct ExpandedSetView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ExpandedSetView(selectedSet: .constant(.example), namespace: namespace)
    }
}
