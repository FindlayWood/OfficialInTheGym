//
//  RecordingOverlay.swift
//  MyDayKit
//
//  Created by Findlay Wood on 16/09/2025.
//

import SwiftUI

struct RecordingOverlay: View {
    
    @State private var countDownOn: Bool = false
    @State private var countDown: Int?
    
    let isRecording: Bool
    
    var flipCamera: (() -> ())?
    
    var startRecording: (() -> ())?
    var stopRecording: (() -> ())?
    var dismiss: (() -> ())?
    
    var body: some View {
        VStack {
            if !isRecording {
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
                    
                    Button {
                        countDownOn.toggle()
                    } label: {
                        Image(systemName: "clock")
                            .foregroundStyle(Color.white)
                            .padding()
                            .background {
                                Circle()
                                    .frame(width: 30)
                                    .foregroundStyle(countDownOn ? Color.green : Color.blue)
                            }
                    }
                    
                    Spacer()
                    
                    Button {
                        flipCamera?()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundStyle(Color.white)
                            .padding()
                            .background {
                                Circle()
                                    .frame(width: 30)
                                    .foregroundStyle(Color.blue)
                            }
                    }
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                if let countDown {
                    Text("\(countDown)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundStyle(Color.black)
                        .padding()
                } else if isRecording {
                    Button {
                        stopRecording?()
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.red)
                            .frame(width: 50, height: 50)
                    }
                } else {
                    Button {
                        startButtonAction()
                    } label: {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .foregroundStyle(Color.blue)
                            }
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func startButtonAction() {
        if countDownOn {
            runCountdown()
        } else {
            startRecording?()
        }
    }
    
    private func runCountdown() {
        var timeLeft = 10
        countDown = 10
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            timeLeft -= 1
            self.countDown = timeLeft
            
            if timeLeft <= 0 {
                timer.invalidate()
                self.countDownOn = false
                self.countDown = nil
                self.startRecording?()
            }
        }
    }
}

#Preview {
    RecordingOverlay(isRecording: false)
}
