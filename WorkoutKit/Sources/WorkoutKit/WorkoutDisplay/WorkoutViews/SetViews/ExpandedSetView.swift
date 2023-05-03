//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 01/05/2023.
//

import SwiftUI

struct ExpandedSetView: View {
    
    @ObservedObject var selectedSet: SetController
    @State private var showing: Bool = true
    
    let namespace: Namespace.ID
    
    var dismiss: () -> ()
    
    var body: some View {
        if showing {
            Color.black.opacity(0.3).ignoresSafeArea()
                .transition(.scale)
        }
        VStack {
            HStack {
                Spacer()
                Button {
                    showing = false
                    dismiss()
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
                selectedSet.completed = true
            } label: {
                Image(systemName: selectedSet.completed ? "checkmark.circle.fill" : "circle")
                    .font(.headline)
            }
            .animation(.easeIn, value: selectedSet.completed)
            .disabled(selectedSet.completed)
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
        .animation(.easeIn, value: selectedSet.completed)
    }
}

struct ExpandedSetView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        ExpandedSetView(selectedSet: .example, namespace: namespace) {}
    }
}
