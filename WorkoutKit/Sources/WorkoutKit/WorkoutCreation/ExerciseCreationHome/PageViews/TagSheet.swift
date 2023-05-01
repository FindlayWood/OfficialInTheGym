//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import SwiftUI

struct TagSheet: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var text: String = ""
    
    var currentTags: [TagModel]
    
    var action: (String) -> ()
    
    var body: some View {
        VStack {
            Image(systemName: "tag.fill")
                .font(.largeTitle.bold())
                .foregroundColor(Color(.darkColour))
                .padding()
            Text("Add a new tag for this workout. Tags help people search for workouts and could include the body part the workout targets, the kind of workout it is, how often to perform the workout etc.")
                .font(.body.weight(.medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(Color(.darkColour))
                TextField("tag...", text: $text)
                    .tint(Color(.darkColour))
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)
            .padding(.vertical)
            
            HStack {
                Text("#\(text.lowercased().filter { !$0.isWhitespace})")
                    .font(.headline)
                    .padding()
            }
            .frame(maxWidth: .infinity)
            .overlay(
                Capsule()
                    .stroke(Color(.darkColour), lineWidth: 2)
            )
            Button {
                action(text.lowercased().filter { !$0.isWhitespace })
                dismiss()
            } label: {
                Text("Add Tag")
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color(.darkColour).opacity(canAdd ? 1 : 0.3))
                    .clipShape(Capsule())
                    .shadow(radius: canAdd ? 1 : 0.3)
            }
            .disabled(!canAdd)
        }
        .padding()
    }
    
    var canAdd: Bool {
        !text.isEmpty || !currentTags.contains { $0.tag == text }
    }
}

struct TagSheet_Previews: PreviewProvider {
    static var previews: some View {
        TagSheet(currentTags: [], action: { _ in } )
    }
}
