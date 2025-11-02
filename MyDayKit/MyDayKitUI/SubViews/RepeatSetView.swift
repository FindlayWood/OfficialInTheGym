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
            VStack {
                Image(systemName: "arrow.counterclockwise")
                Text("Repeat")
            }
            .padding()
            .frame(width: 100, height: 100)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 1)
            }
        }
    }
}

#Preview {
    RepeatSetView()
}
