//
//  PlayBackSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 24/01/2026.
//

import SwiftUI

struct PlayBackSheet: View {
    
    @Binding var videoPublic: Bool
    
    var upload: (() -> ())?
    var saveToCameraRoll: (() -> ())?
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Handle indicator
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color(UIColor.tertiaryLabel))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                
                // Title
                HStack {
                    Text("Post your clip")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                VStack(spacing: 12) {
                    
                    // ── Visibility toggle ──────────────────────────────
                    VStack(spacing: 12) {
                        HStack(alignment: .center) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(videoPublic ? Color.blue.opacity(0.12) : Color(UIColor.tertiarySystemBackground))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: videoPublic ? "globe" : "lock.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(videoPublic ? Color.blue : Color(UIColor.secondaryLabel))
                                    .animation(.easeInOut(duration: 0.2), value: videoPublic)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Share publicly")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                                Text(videoPublic ? "Visible to everyone" : "Only visible to you")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.secondary)
                                    .animation(.easeInOut(duration: 0.2), value: videoPublic)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $videoPublic)
                                .labelsHidden()
                                .tint(Color.blue)
                        }
                        
                        if videoPublic {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.blue.opacity(0.8))
                                Text("Sharing publicly helps others discover new exercises and movements.")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.blue.opacity(0.06))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .padding(16)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .animation(.easeInOut(duration: 0.25), value: videoPublic)
                    
                    // ── Save to camera roll ────────────────────────────
                    Button {
                        saveToCameraRoll?()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Save to Camera Roll")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.primary)
                                Text("Keep a copy on your device")
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color(UIColor.tertiaryLabel))
                        }
                        .padding(16)
                        .background(Color(UIColor.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // ── Upload button ──────────────────────────────────────
                Button {
                    upload?()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Upload Clip")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.hidden)
        .presentationCornerRadius(28)
    }
}

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            PlayBackSheet(videoPublic: .constant(true))
                .presentationDetents([.medium])
        }
    
}
