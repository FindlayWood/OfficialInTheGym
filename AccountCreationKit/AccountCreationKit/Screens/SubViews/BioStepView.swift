//
//  BioStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct BioStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    @State private var placeholder: String = "write something about you..."

    var body: some View {
        VStack(alignment: .leading) {
            Text("Bio")
                .font(.title.bold())
                .foregroundColor(.primary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.bio)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
                TextEditor(text: $placeholder)
                    .foregroundColor(.secondary)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
                    .opacity(viewModel.bio.isEmpty ? 0.4 : 0)
            }

            HStack {
                Spacer()
                Text(viewModel.bio.count, format: .number)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    BioStepView(viewModel: .preview)
}
