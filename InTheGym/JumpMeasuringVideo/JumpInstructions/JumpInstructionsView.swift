//
//  JumpInstructionsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 23/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct JumpInstructionsView: View {
    var instructions: [JumpInstruction]
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(Color(.darkColour))
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
                Image("instructions_icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                ForEach(instructions, id: \.self) {
                    JumpInstructionSubview(number: $0.number, instruction: $0.instruction)
                        .padding()
                }
            }
        }
    }
}

struct JumpInstructionSubview: View {
    var number: Int
    var instruction: String
    var body: some View {
        HStack {
            Text(number.description + ".")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(instruction)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct JumpInstruction: Hashable {
    var id = UUID()
    var number: Int
    var instruction: String
}

struct JumpInstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        JumpInstructionsView(instructions: [])
    }
}
