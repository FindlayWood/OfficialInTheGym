//
//  SelectRoleRow.swift
//
//
//  Created by Findlay-Personal on 04/02/2024.
//

import SwiftUI

struct SelectRoleRow: View {
    
    let role: ClubRole
    let selected: Bool
    
    let selectedBackgroundGradient: LinearGradient = LinearGradient(colors: [Color(.lightColour), Color(.darkColour)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let unSelectedBackgroundGradient: LinearGradient = LinearGradient(colors: [Color(.offWhiteColour), Color(.white)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let unSelectedImageGradient: LinearGradient = LinearGradient(colors: [Color.black.opacity(0.3), Color.black.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var shadowColor: Color {
        selected ? .black.opacity(0.3) : Color.clear
    }
    
    var shadowRadius: CGFloat {
        selected ? 4 : 0
    }
    
    var action: () -> ()
    
    var body: some View {
        VStack {
            Image(systemName: role.iconName)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
                .foregroundStyle(selected ? selectedBackgroundGradient : unSelectedImageGradient)

            Text(role.rawValue.capitalized)
                .font(.headline)
                .foregroundStyle(selected ? selectedBackgroundGradient : unSelectedImageGradient)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            (unSelectedBackgroundGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: shadowColor, radius: shadowRadius, y: 2)
        )
        .onTapGesture {
            action()
        }
    }
}

#Preview {
    SelectRoleRow(role: .player, selected: true) {}
}
