//
//  JumpInstructionsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// How to do a jump test, as a sheet: its numbered steps in one card.
struct JumpInstructionsScreen: View {

    @Environment(\.dismiss) private var dismiss
    let kind: JumpTestKind

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    PerformanceSectionHeader(title: kind.title)
                    let instructions = JumpInstruction.all(for: kind)
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
