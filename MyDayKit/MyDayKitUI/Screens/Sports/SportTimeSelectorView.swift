//
//  SportTimeSelectorView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 11/03/2026.
//

import SwiftUI

struct SportTimeSelectorView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let subtitle: String
    let color: Color
    let onSave: (Int) -> Void
    
    @State private var value: Int
    
    private var isValid: Bool { value > 0 }
    
    let steps: [Int] = [1, 5, 10, 30, 60, 300]
    let columns = Array(repeating: GridItem(.flexible()), count: 3)
    
    init(
        title: String,
        subtitle: String,
        currentValue: Int,
        color: Color,
        onSave: @escaping (Int) -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.onSave = onSave
        self._value = State(initialValue: currentValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(UIColor.tertiaryLabel))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.primary)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.secondary)
            }
            .padding(.bottom, 20)
            
            // Time display
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                timeComponent(value: value / 3600, unit: "h")
                timeComponent(value: (value % 3600) / 60, unit: "m")
                timeComponent(value: value % 60, unit: "s")
            }
            .contentTransition(.numericText())
            .animation(.easeInOut(duration: 0.15), value: value)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(UIColor.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            
            // Steps
            VStack(spacing: 12) {
                stepSection(label: "Remove", icon: "minus.circle.fill", color: .red, disabled: value == 0) { step in
                    withAnimation(.easeInOut(duration: 0.15)) { value = max(0, value - step) }
                }
                Divider()
                stepSection(label: "Add", icon: "plus.circle.fill", color: color, disabled: false) { step in
                    withAnimation(.easeInOut(duration: 0.15)) { value = min(86400, value + step) }
                }
            }
            .padding(.horizontal, 16)
            
            Spacer()
            
            Button {
                onSave(value)
                dismiss()
            } label: {
                Text(isValid ? "Set \(formattedDuration(value))" : "Select a duration")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isValid ? Color.white : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isValid ? color : Color(UIColor.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .disabled(!isValid)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
    
    @ViewBuilder
    private func timeComponent(value: Int, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text("\(value)")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(value > 0 ? Color.primary : Color(UIColor.tertiaryLabel))
                .monospacedDigit()
            Text(unit)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .padding(.bottom, 4)
        }
    }
    
    @ViewBuilder
    private func stepSection(
        label: String,
        icon: String,
        color: Color,
        disabled: Bool,
        onStep: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(color.opacity(0.7))
                Text(label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(steps, id: \.self) { step in
                    Button {
                        onStep(step)
                    } label: {
                        Text(formattedStep(step))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(disabled ? Color(UIColor.tertiaryLabel) : Color.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                disabled
                                    ? Color(UIColor.tertiarySystemBackground)
                                    : color.opacity(0.08)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(disabled)
                }
            }
        }
    }
    
    private func formattedStep(_ step: Int) -> String {
        if step >= 3600 { return "\(step / 3600)h" }
        if step >= 60   { return "\(step / 60)m" }
        return "\(step)s"
    }
    
    private func formattedDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 { return s == 0 ? "\(h)h \(m)m" : "\(h)h \(m)m \(s)s" }
        if m > 0 { return s == 0 ? "\(m)m" : "\(m)m \(s)s" }
        return "\(s)s"
    }
}

#Preview {
    SportTimeSelectorView(title: "", subtitle: "", currentValue: 0, color: .green, onSave: { _ in })
}
