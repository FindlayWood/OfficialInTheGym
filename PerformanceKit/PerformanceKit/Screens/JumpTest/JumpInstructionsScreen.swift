//
//  JumpInstructionsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// How to do a test, as a sheet: its numbered steps in one card. Every test
/// uses it, jump or balance.
struct JumpInstructionsScreen: View {

    @Environment(\.dismiss) private var dismiss
    let title: String
    let instructions: [JumpInstruction]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    PerformanceSectionHeader(title: title)
                    VStack(spacing: 0) {
                        ForEach(instructions, id: \.self) { instruction in
                            JumpInstructionRow(
                                instruction: instruction,
                                showsDivider: instruction.number < instructions.count
                            )
                        }
                    }
                    .performanceCard()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("How It Works")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .tint(Color.darkColor)
                }
            }
        }
    }
}
