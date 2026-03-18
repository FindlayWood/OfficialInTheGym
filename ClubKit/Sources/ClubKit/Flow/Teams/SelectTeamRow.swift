//
//  SelectTeamRow.swift
//  
//
//  Created by Findlay Wood on 28/02/2024.
//

import SwiftUI

struct SelectTeamRow: View {
    
    let selected: Bool
    let team: RemoteTeamModel
    
    let selectedBackgroundGradient: LinearGradient = LinearGradient(colors: [Color(.lightColour), Color(.darkColour)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let unSelectedBackgroundGradient: LinearGradient = LinearGradient(colors: [Color(.offWhiteColour), Color(.white)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let unSelectedImageGradient: LinearGradient = LinearGradient(colors: [Color.white, Color.white], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var shadowColor: Color {
        selected ? .black.opacity(0.3) : Color.clear
    }
    
    var shadowRadius: CGFloat {
        selected ? 4 : 0
    }
    
    var action: () -> ()
    
    var body: some View {
        HStack {
            Text(team.teamName)
                .font(.headline)
                .foregroundStyle(selected ? Color.primary : Color.primary.opacity(0.3))
            Spacer()
            Button {
                action()
            } label: {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundStyle(selectedBackgroundGradient)
            }
        }
        .padding()
        .background(
            (selected ? unSelectedBackgroundGradient : unSelectedImageGradient )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: shadowColor, radius: shadowRadius, y: 4)
        )
    }
}

#Preview {
    SelectTeamRow(selected: false, team: .example, action: {})
}
