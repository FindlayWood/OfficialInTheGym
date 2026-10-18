//
//  LoginFieldPrompt.swift
//  LoginKit
//
//  Created by Findlay Wood on 18/10/2026.
//

import SwiftUI

/// The placeholder for every LoginKit field: an instruction, in the system placeholder colour.
///
/// The email fields used to show `you@example.com`, which is shaped exactly like an answer — on a
/// light well it read as an address already filled in, and people tapped past a field they thought
/// was done. **A placeholder says what to type, never an example of it.** The colour is pinned to
/// `placeholderText` so a `foregroundStyle` or `tint` on the field can never make the prompt look
/// like entered text.
enum LoginFieldPrompt {

    static func text(_ string: String) -> Text {
        Text(string).foregroundStyle(Color(UIColor.placeholderText))
    }
}
