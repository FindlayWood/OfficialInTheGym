//
//  RepeatSetView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 02/11/2025.
//

import SwiftUI

struct RepeatSetView: View {
    
    var action: (() -> ())?
    
    var body: some View {
        Button {
            action?()
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.blue)
                
                Text("Repeat")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.blue)
            }
            .frame(width: 60, height: 60)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.borderless)
    }
}

#Preview {
    RepeatSetView()
}
