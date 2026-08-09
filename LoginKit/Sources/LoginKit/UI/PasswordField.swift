//
//  PasswordField.swift
//  LoginKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

/// A password entry with a reveal toggle, shared by login and signup rather than written twice.
///
/// The eye used to be `.foregroundColor(.black)` — invisible against a dark background — and the
/// field had no `textContentType`, so iOS never offered a saved or generated password.
struct PasswordField: View {

    let placeholder: String
    @Binding var password: String

    /// `.password` on login so the keychain offers an existing one; `.newPassword` on signup so it
    /// offers to generate and save one instead.
    let contentType: UITextContentType

    @State private var isRevealed: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isRevealed {
                    TextField(placeholder, text: $password)
                } else {
                    SecureField(placeholder, text: $password)
                }
            }
            .font(.system(size: 16))
            .tint(Color.darkColor)
            .textContentType(contentType)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)

            Button {
                isRevealed.toggle()
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
    }
}
