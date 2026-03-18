//
//  PlaybackOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import SwiftUI

struct PlaybackOverlay: View {
    
    let progress: Double
    let isPlaying: Bool  // new — to show play/pause state
    
    var onTogglePlayPause: (() -> ())?
    var options: (() -> ())?
    var dismiss: (() -> ())?
    var upload: (() -> ())?
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Progress bar ───────────────────────────────────────────
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 3)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * progress, height: 3)
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
            .frame(height: 3)
            .padding(.top, 8)
            
            // ── Top bar ────────────────────────────────────────────────
            HStack {
                // Dismiss
                Button {
                    dismiss?()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Preview label
                Text("Preview")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                
                Spacer()
                
                // Options
                Button {
                    options?()
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.4))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // ── Centre tap area for play/pause ─────────────────────────
            Spacer()
            
            if !isPlaying {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color.white)
                        .offset(x: 2) // optical centre for play icon
                }
                .onTapGesture {
                    onTogglePlayPause?()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.8)))
            }
            
            Spacer()
            
            // ── Bottom bar ─────────────────────────────────────────────
            HStack(alignment: .bottom, spacing: 12) {
                
                // Save to camera roll — secondary action
                VStack(spacing: 6) {
                    Button {
                        options?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: "ellipsis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    Text("More")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
                
                Spacer()
                
                // Upload — primary action, centre and larger
                VStack(spacing: 6) {
                    Button {
                        upload?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 68, height: 68)
                                .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 4)
                            
                            Image(systemName: "arrow.up")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    Text("Upload")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                
                Spacer()
                
                // Retake — secondary action
                VStack(spacing: 6) {
                    Button {
                        dismiss?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 52, height: 52)
                            
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.white)
                        }
                    }
                    Text("Retake")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 48)
        }
        .animation(.easeInOut(duration: 0.2), value: isPlaying)
    }
}

#Preview {
    PlaybackOverlay(progress: 1, isPlaying: true)
        .background {
            Color.black.ignoresSafeArea()
        }
}
