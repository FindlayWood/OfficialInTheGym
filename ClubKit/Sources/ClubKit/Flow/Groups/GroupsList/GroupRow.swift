//
//  SwiftUIView.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import SwiftUI

struct GroupRow: View {
    
    let model: RemoteGroupModel
    
    var body: some View {
        HStack {
            Text(model.name)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            
            Image(systemName: "person.3.fill")
                .foregroundColor(Color(.darkColour))
            Text(model.members.count, format: .number)
                .font(.footnote.bold())
                .foregroundColor(.secondary)
                .foregroundColor(Color(.darkColour))
                .padding(.vertical)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.darkColour), lineWidth: 1)
        )

    }
}

struct GroupRow_Previews: PreviewProvider {
    static var previews: some View {
        GroupRow(model: .example)
    }
}
