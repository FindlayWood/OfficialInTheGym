//
//  SessionSetTempoSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import SwiftUI

/// Enters the tempo actually performed on a set.
///
/// Deliberately mirrors `MyDayTempoSelectorView` — same four columns, same
/// +/− steppers, same live preview — because that is where the user already
/// learned to enter a tempo. It is the one measure the `CustomNumberPad` does
/// not suit: four values entered together read as one figure, and stepping is
/// how a tempo is adjusted.
///
/// Binds live: "Done" only dismisses.
struct SessionSetTempoSheet: View {

    let exerciseName: String
    let setNumber: Int
    let targetSummary: String?

    /// `nil` while the set has no performed tempo. Cleared back to `nil` by
    /// "Clear", so an untouched tempo is never stored as 0–0–0–0.
    @Binding var tempo: Tempo?

    @Environment(\.dismiss) private var dismiss

    private var working: Tempo { tempo ?? Tempo() }

    private var hasTempo: Bool { !(tempo?.isEmpty ?? true) }

    private var tempoString: String {
        "\(working.eccentric)–\(working.eccentricHold)–\(working.concentric)–\(working.concentricHold)"
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            preview
            columns

            if let targetSummary {
                targetReference(targetSummary)
            }

            Spacer(minLength: 0)

            if hasTempo {
                clearButton
            }

            doneButton
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {
            Text(exerciseName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            Text("Tempo · Set \(setNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
            Text("Down · Hold · Up · Hold")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    // MARK: - Preview

    private var preview: some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text(hasTempo ? tempoString : "–")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(hasTempo ? Color.primary : Color(UIColor.tertiaryLabel))
                .contentTransition(.numericText())
                .lineLimit(1)
                .minimumScaleFactor(0.6)

            if hasTempo {
                Text("sec")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.secondary)
                    .padding(.bottom, 4)
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .animation(.easeInOut(duration: 0.15), value: tempoString)
        .animation(.easeInOut(duration: 0.15), value: hasTempo)
    }

    // MARK: - Columns

    private var columns: some View {
        HStack(spacing: 10) {
            column(label: "Down", sublabel: "Eccentric", keyPath: \.eccentric)
            column(label: "Hold", sublabel: "Bottom", keyPath: \.eccentricHold)
            column(label: "Up", sublabel: "Concentric", keyPath: \.concentric)
            column(label: "Hold", sublabel: "Top", keyPath: \.concentricHold)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }

    private func column(
        label: String,
        sublabel: String,
        keyPath: WritableKeyPath<Tempo, Int>
    ) -> some View {
        let value = working[keyPath: keyPath]

        return VStack(spacing: 10) {
            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.primary)
                Text(sublabel)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundStyle(Color.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Button {
                adjust(keyPath, to: value + 1)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.darkColor.opacity(0.1))
                        .frame(height: 40)
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.darkColor)
                }
            }
            .buttonStyle(.plain)

            Text("\(value)")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(value > 0 ? Color.primary : Color(UIColor.tertiaryLabel))
                .frame(height: 32)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.15), value: value)

            Button {
                adjust(keyPath, to: max(0, value - 1))
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(value > 0 ? Color.red.opacity(0.1) : Color(UIColor.tertiarySystemBackground))
                        .frame(height: 40)
                    Image(systemName: "minus")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(value > 0 ? Color.red : Color(UIColor.tertiaryLabel))
                }
            }
            .buttonStyle(.plain)
            .disabled(value == 0)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    /// Stepping back to all-zeros means "no tempo", not "a tempo of zero" —
    /// otherwise an empty tempo would render as 0–0–0–0 on the set card.
    private func adjust(_ keyPath: WritableKeyPath<Tempo, Int>, to newValue: Int) {
        var updated = working
        updated[keyPath: keyPath] = newValue
        tempo = updated.isEmpty ? nil : updated
    }

    // MARK: - Target Reference

    private func targetReference(_ summary: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "target")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.secondary)
            Text("Target")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
            Text(summary)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
    }

    // MARK: - Buttons

    private var clearButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                tempo = nil
            }
        } label: {
            Text("Clear")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.red)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 24)
    }

    private var doneButton: some View {
        Button {
            dismiss()
        } label: {
            Text("Done")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.darkColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var tempo: Tempo? = Tempo(eccentric: 3, eccentricHold: 1, concentric: 1, concentricHold: 0)

    Color.darkColor
        .sheet(isPresented: .constant(true)) {
            SessionSetTempoSheet(
                exerciseName: "Back Squat",
                setNumber: 2,
                targetSummary: "3–1–1–0",
                tempo: $tempo
            )
            .presentationDetents([.height(620)])
        }
}
