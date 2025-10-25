//
//  ClipPlaybackScreen.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import SwiftUI

struct ClipPlaybackScreen: View {
    
    var dismiss: (() -> ())?
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    dismiss?()
                } label: {
                    Image(systemName: "x.circle")
                        .foregroundStyle(Color.white)
                        .padding()
                        .background {
                            Circle()
                                .frame(width: 30)
                                .foregroundStyle(Color.blue)
                        }
                }
                Spacer()
            }
            Spacer()
            
            HStack {
                Button {
                    
                } label: {
                    Text("Upload")
                }
                
                Button {
                    
                } label: {
                    Text("Save")
                }
            }
        }
    }
}


#Preview {
    ClipPlaybackScreen()
}
