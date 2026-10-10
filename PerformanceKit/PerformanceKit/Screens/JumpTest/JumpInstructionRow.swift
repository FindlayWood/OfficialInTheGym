//
//  JumpInstructionRow.swift
//  PerformanceKit
//
//  Created by Findlay Wood on 10/10/2026.
//
import SwiftUI

/// One step of the instructions: its number in a `darkColor` circle, then
/// the step.
struct JumpInstructionRow: View {

    let instruction: JumpInstruction
    var showsDivider = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Text("\(instruction.number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Circle().fill(Color.darkColor))
                Text(instruction.instruction)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            .padding(16)
            if showsDivider {
                Divider().padding(.leading, 58)
            }
        }
    }
}
