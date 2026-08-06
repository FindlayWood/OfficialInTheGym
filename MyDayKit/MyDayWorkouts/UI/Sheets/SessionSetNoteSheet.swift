//
//  SessionSetNoteSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 06/08/2026.
//

import SwiftUI

/// Writes a note against a set as performed — "felt heavy", "left knee caved",
/// "dropped a plate on the last rep".
///
/// The one place in an active session that uses the system keyboard. Every
/// numeric measure goes through `CustomNumberPad` via `SessionSetValueSheet`
/// and must stay there; free text has no equivalent, and a note the user cannot
/// type is not a note. **Do not extend this sheet to numbers.**
///
/// Binds live: "Done" only dismisses.
struct SessionSetNoteSheet: View {

    let exerciseName: String
    let setNumber: Int

    /// The template's own note, shown for reference. It is the coach's
    /// instruction and is never edited here — this sheet writes to the record.
    let prescribedNote: String?

    @Binding var note: String

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var hasNote: Bool {
        !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            if let prescribedNote {
                prescribed(prescribedNote)
            }

            editor

            Spacer(minLength: 0)

            doneButton
        }
        .onAppear { isFocused = true }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 4) {
            Text(exerciseName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.secondary)
                .lineLimit(1)
            Text("Note · Set \(setNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }

    // MARK: - Prescribed Note

    private func prescribed(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "target")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.secondary)
                .padding(.top, 2)
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Editor

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(UIColor.secondarySystemBackground))

            if !hasNote {
                Text("How did the set feel?")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(UIColor.tertiaryLabel))
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .allowsHitTesting(false)
            }

            TextEditor(text: $note)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.primary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
        }
        .frame(height: 120)
        .padding(.horizontal, 16)
    }

    // MARK: - Done

    private var doneButton: some View {
        Button {
            isFocused = false
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
        .padding(.top, 16)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var note = ""

    Color.darkColor
        .sheet(isPresented: .constant(true)) {
            SessionSetNoteSheet(
                exerciseName: "Back Squat",
                setNumber: 2,
                prescribedNote: "Pause at the bottom, drive through the heels.",
                note: $note
            )
            .presentationDetents([.height(400)])
        }
}
