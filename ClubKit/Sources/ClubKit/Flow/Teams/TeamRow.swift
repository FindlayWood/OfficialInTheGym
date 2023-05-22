//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import SwiftUI

struct TeamRow: View {
    
    var model: RemoteTeamModel
    
    var body: some View {
        HStack {
            Text(model.teamName)
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            
            Image(systemName: "person.3.fill")
            Text(model.athleteCount, format: .number)
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

struct TeamRow_Previews: PreviewProvider {
    static var previews: some View {
        TeamRow(model: .example)
    }
}
