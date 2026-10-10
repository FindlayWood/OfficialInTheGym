//
//  JumpInstructionsScreen.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// How to measure a jump, as a sheet: six numbered steps in one card.
struct JumpInstructionsScreen: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    PerformanceSectionHeader(title: "Measuring a jump")
                    VStack(spacing: 0) {
                        ForEach(JumpInstruction.all, id: \.self) { instruction in
                            JumpInstructionRow(
                                instruction: instruction,
                                showsDivider: instruction.number < JumpInstruction.all.count
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
