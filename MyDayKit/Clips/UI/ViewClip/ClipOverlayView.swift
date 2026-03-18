//
//  ClipOverlayView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 05/03/2026.
//

import SwiftUI

struct ClipOverlayView: View {
    
    var onClose: (() -> ())?
    var onTogglePlayPause: (() -> ())?
    
    var body: some View {
        ZStack {
            
            // ── Full screen tap for play/pause ─────────────────────────
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    onTogglePlayPause?()
                }
            
            VStack(spacing: 0) {
                
                // ── Top bar ────────────────────────────────────────────
                HStack {
                    Button {
                        onClose?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 44, height: 44)
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    ClipOverlayView()
}
