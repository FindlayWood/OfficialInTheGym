//
//  ErrorPopoverView.swift
//  InTheGym
//
//  Created by Findlay-Personal on 19/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct ErrorPopoverView: View {
    
    @Binding var isShowing: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            VStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .padding()
                Text("Error!")
                Text("Oops it seemed like something has gone wrong. Please try again in a few moments.")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
                Button {
                    isShowing = false
                } label: {
                    Text("Ok")
                }
                .padding()
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
        }
    }
}

struct ErrorPopoverView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorPopoverView(isShowing: .constant(false))
    }
}
