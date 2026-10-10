//
//  JumpInstructionsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// How to measure a jump, presented as a sheet. The legacy
/// `JumpInstructionsView`, moved as it was, except that **its close button now
/// closes it**. The legacy button had an empty action, so the sheet could only
/// be swiped away.
struct JumpInstructionsScreen: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color.darkColor)
                    }
                    .padding()
                    Spacer()
                }
                Text("Instructions")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity)
                    .padding()
                Image("instructions_icon", bundle: .performanceKit)
                    .resizable()
                    .frame(width: 100, height: 100)
                ForEach(JumpInstruction.all, id: \.self) {
                    JumpInstructionRow(instruction: $0)
                        .padding()
                }
            }
        }
        .background(Color(.systemBackground))
    }
}
