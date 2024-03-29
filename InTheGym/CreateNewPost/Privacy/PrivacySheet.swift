//
//  PrivacySheet.swift
//  InTheGym
//
//  Created by Findlay-Personal on 26/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct PrivacySheet: View {
    
    // MARK: - Published Variables
    @State var isPrivate: Bool
    @State var optionChanged: Bool = false
    
    // MARK: - Call backs
    var action: (Bool) -> ()
    var dismiss: () -> ()
    
    // MARK: - View
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                VStack(alignment: .leading) {
                    Text("Privacy")
                        .font(.title.weight(.semibold))
                        .foregroundColor(.primary)
                    Text("Choose privacy options. Remember that all InTheGym users have to verify their accounts before logging in. Choosing PRIVATE will restrict access to only followers and coaches/players. Choosing PUBLIC will allow access to all InTheGym users.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.title)
                                    .foregroundColor(Color(.darkColour))
                                Text("Public")
                                    .font(.title3.bold())
                                    .foregroundColor(Color(.darkColour))
                            }
                            .padding(.bottom)
                            Text("Choosing PUBLIC will allow access to all InTheGym users. Confirm your choice by tapping Confirm Changes.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                        }
                        Spacer()
                        Button {
                            isPrivate = false
                        } label: {
                            Image(systemName: isPrivate ? "circle" : "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.darkColour), lineWidth: 2)
                }
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .font(.title)
                                    .foregroundColor(Color(.darkColour))
                                Text("Private")
                                    .font(.title3.bold())
                                    .foregroundColor(Color(.darkColour))
                            }
                            .padding(.bottom)
                            Text("Choosing PRIVATE will restrict access to only followers and coaches/players. Confirm your choice by tapping Confirm Changes.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                        }
                        Spacer()
                        Button {
                            isPrivate = true
                        } label: {
                            Image(systemName: isPrivate ? "checkmark.circle.fill" : "circle")
                                .font(.title)
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                }
                .padding()
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.darkColour), lineWidth: 2)
                }
                if optionChanged {
                    Button {
                        action(isPrivate)
                    } label: {
                        Text("Confirm Change")
                            .font(.title3.bold())
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("dismiss")
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
            .onChange(of: isPrivate) { _ in
                optionChanged = true
            }
        }
    }
}

struct PrivacySheet_Previews: PreviewProvider {
    static var previews: some View {
        PrivacySheet(isPrivate: false, action: { _ in}, dismiss: {})
    }
}
