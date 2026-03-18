//
//  RecordingOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import SwiftUI

struct RecordingOverlay: View {
    
    @State private var countDownOn: Bool = false
    @State private var countDownStarted: Bool = false
    @State private var countDown: Int?
    
    let isRecording: Bool
    let recordingProgress: Double      // 0.0 – 1.0 from VideoRecorder
    let recordingDuration: Double      // seconds from VideoRecorder
    let isBelowMinimumDuration: Bool   // from VideoRecorder
    
    var flipCamera: (() -> ())?
    var startRecording: (() -> ())?
    var stopRecording: (() -> ())?
    var dismiss: (() -> ())?
    
    // 5 / 16 = where the minimum threshold sits on the bar
    private let minimumThreshold: Double = 5.0 / 16.0
    private let maxDuration: Double = 16.0
    
    var body: some View {
        VStack(spacing: 0) {
            
            // ── Progress bar ───────────────────────────────────────────
            if isRecording {
                progressBar
                    .transition(.opacity)
            }
            
            // ── Top controls ───────────────────────────────────────────
            if !isRecording && !countDownStarted {
                topControls
            }
            
            Spacer()
            
            // ── Bottom controls ────────────────────────────────────────
            bottomControls
                .padding(.bottom, 40)
        }
        .animation(.easeInOut(duration: 0.2), value: isRecording)
    }
    
    // MARK: - Progress Bar
    
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                
                // Track
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                // Filled portion — red before minimum, white after
                Rectangle()
                    .fill(progressBarColor)
                    .frame(
                        width: geo.size.width * recordingProgress,
                        height: 4
                    )
                    .animation(.linear(duration: 0.05), value: recordingProgress)
                
                // Minimum threshold tick mark
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 12)
                    .offset(x: geo.size.width * minimumThreshold - 1)
            }
        }
        .frame(height: 12) // enough height for the tick mark to show
        .padding(.horizontal, 0)
    }
    
    private var progressBarColor: Color {
        if isBelowMinimumDuration {
            return Color.yellow
        } else {
            return Color.white
        }
    }
    
    // MARK: - Timer display
    
    private var timerText: String {
        let total = Int(recordingDuration)
        let seconds = total % 60
        let minutes = total / 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Top Controls
    
    private var topControls: some View {
        HStack {
            // Dismiss
            Button {
                dismiss?()
            } label: {
                overlayIconButton(systemName: "xmark")
            }
            
            Spacer()
            
            // Countdown toggle
            Button {
                countDownOn.toggle()
            } label: {
                ZStack {
                    Circle()
                        .fill(countDownOn ? Color.blue : Color.black.opacity(0.4))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: countDownOn ? "timer" : "timer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
            }
            
            Spacer()
            
            // Flip camera
            Button {
                flipCamera?()
            } label: {
                overlayIconButton(systemName: "arrow.triangle.2.circlepath")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - Shared button style
    
    @ViewBuilder
    private func overlayIconButton(systemName: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.4))
                .frame(width: 44, height: 44)
            
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
        }
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControls: some View {
        Group {
            if let countDown {
                // Countdown display
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.4))
                        .frame(width: 80, height: 80)
                    
                    Text("\(countDown)")
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color.white)
                        .contentTransition(.numericText())
                }
                
            } else if isRecording {
                // Recording state
                VStack(spacing: 12) {
                    
                    // Timer pill
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 7, height: 7)
                        Text(timerText)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())
                    
                    // Stop button
                    Button {
                        stopRecording?()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.3))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
                            
                            RoundedRectangle(cornerRadius: isBelowMinimumDuration ? 24 : 8)
                                .fill(isBelowMinimumDuration ? Color.gray.opacity(0.8) : Color.red)
                                .frame(width: 34, height: 34)
                                .animation(.easeInOut(duration: 0.3), value: isBelowMinimumDuration)
                        }
                    }
                    
                    // Minimum hint
                    if isBelowMinimumDuration {
                        Text("5s minimum")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black.opacity(0.4))
                            .clipShape(Capsule())
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: isBelowMinimumDuration)
                
            } else {
                // Pre-recording state
                VStack(spacing: 16) {
                    if countDownOn {
                        Text("Timer on")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.8))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue.opacity(0.6))
                            .clipShape(Capsule())
                            .transition(.opacity)
                    }
                    
                    // Record button
                    Button {
                        startButtonAction()
                    } label: {
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 80, height: 80)
                            
                            // Inner filled circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: 64, height: 64)
                            
                            // Blue dot in centre when countdown on
                            if countDownOn {
                                Image(systemName: "timer")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.blue)
                            }
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: countDownOn)
            }
        }
    }
    
    // MARK: - Actions
    
    private func startButtonAction() {
        if countDownOn {
            runCountdown()
        } else {
            startRecording?()
        }
    }
    
    private func runCountdown() {
        countDownStarted = true
        var timeLeft = 10
        countDown = 10
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            timeLeft -= 1
            self.countDown = timeLeft
            
            if timeLeft <= 0 {
                timer.invalidate()
                self.countDownOn = false
                self.countDown = nil
                self.countDownStarted = false
                self.startRecording?()
            }
        }
    }
}

#Preview {
    RecordingOverlay(isRecording: true, recordingProgress: 0.3, recordingDuration: 16, isBelowMinimumDuration: false)
}
