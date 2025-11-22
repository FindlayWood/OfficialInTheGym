//
//  CustomNumberPad.swift
//  MyDayKit
//
//  Created by Findlay Wood on 22/11/2025.
//

import SwiftUI

struct CustomNumberPad: View {
    
    var showingDecimalPoint: Bool = false
    let backspaceDisabled: Bool
    let zeroDisabled: Bool
    
    var selection: ((Int) -> ())?
    var backspace: (() -> ())?
    
    private let gridItems = Array(repeating: GridItem(.fixed(60)), count: 3)
    
    var body: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: gridItems) {
                ForEach(1...9, id: \.self) { number in
                    NumberButton(label: "\(number)", disabled: false) {
                        selection?(number)
                    }
                }
            }
            HStack(spacing: 10) {
                Spacer()
                    .frame(width: 60)
                NumberButton(label: "0", disabled: zeroDisabled) {
                    selection?(0)
                }
                .disabled(zeroDisabled)
                NumberButton(label: "⌫", disabled: backspaceDisabled) {
                    backspace?()
                }
                .disabled(backspaceDisabled)
            }
        }
        .padding()
    }
}

#Preview {
    CustomNumberPad(backspaceDisabled: false, zeroDisabled: false)
}


struct NumberButton: View {
    let label: String
    let disabled: Bool
    let action: (() -> ())?
    
    var body: some View {
        Button {
            action?()
        } label: {
            Text(label)
                .font(.system(size: 28, weight: .medium))
                .foregroundStyle(Color.white)
                .frame(width: 60, height: 60)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(Color.blue.opacity(disabled ? 0.3 : 1))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black.opacity(disabled ? 0.3 : 1), lineWidth: 1)
                        }
                }
        }
    }
}
