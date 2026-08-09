//
//  DisplayNameStepView.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct DisplayNameStepView: View {

    @ObservedObject var viewModel: AccountCreationHomeViewModel

    var body: some View {
        VStack(alignment: .leading) {

            Text("Display Name")
                .font(.title.bold())
                .foregroundColor(.primary)

            HStack {
                Image(systemName: "person.crop.square.fill")
                    .foregroundColor(Color.darkColor)
                TextField("display name", text: $viewModel.displayName)
                    .tint(Color.darkColor)
            }
            .padding()
            .background(.white)
            .clipShape(Capsule())
            .shadow(radius: 8)

            Text("Enter your display name above. We recommend just using your real name.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
                .padding(.bottom)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    DisplayNameStepView(viewModel: .preview)
}
