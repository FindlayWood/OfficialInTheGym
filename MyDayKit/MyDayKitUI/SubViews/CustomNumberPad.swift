//
//  CustomNumberPad.swift
//  MyDayKit
//
//  Created by Findlay Wood on 22/11/2025.
//

import SwiftUI

// MARK: - Custom Number Pad

struct CustomNumberPad: View {
    
    var showingDecimalPoint: Bool = false
    var decimalDisabled: Bool = true
    let backspaceDisabled: Bool
    let zeroDisabled: Bool
    
    var decimalSelected: (() -> ())?
    var selection: ((Int) -> ())?
    var backspace: (() -> ())?
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    var body: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(1...9, id: \.self) { number in
                    NumberButton(label: "\(number)", disabled: false) {
                        selection?(number)
                    }
                }
            }
            
            HStack(spacing: 8) {
                if showingDecimalPoint {
                    NumberButton(label: ".", disabled: decimalDisabled) {
                        decimalSelected?()
                    }
                    .disabled(decimalDisabled)
                } else {
                    // Empty placeholder to keep 0 centred
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
                
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
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
}

#Preview {
    CustomNumberPad(backspaceDisabled: false, zeroDisabled: false)
}

// MARK: - Number Button

struct NumberButton: View {
    
    let label: String
    let disabled: Bool
    let action: () -> Void
    
    var isBackspace: Bool { label == "⌫" }
    
    var body: some View {
        Button(action: action) {
            Group {
                if isBackspace {
                    Image(systemName: "delete.left")
                        .font(.system(size: 18, weight: .medium))
                } else {
                    Text(label)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                }
            }
            .foregroundStyle(disabled ? Color(UIColor.tertiaryLabel) : Color.primary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                disabled
                    ? Color(UIColor.tertiarySystemBackground)
                    : Color(UIColor.secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(disabled)
    }
}
