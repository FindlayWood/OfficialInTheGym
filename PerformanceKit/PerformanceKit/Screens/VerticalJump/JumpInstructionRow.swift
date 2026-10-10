//
//  JumpInstructionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One step of the instructions. The legacy `JumpInstructionSubview`.
struct JumpInstructionRow: View {

    let instruction: JumpInstruction

    var body: some View {
        HStack {
            Text(instruction.number.description + ".")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(instruction.instruction)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
