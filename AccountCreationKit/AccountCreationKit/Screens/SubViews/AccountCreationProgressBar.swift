//
//  AccountCreationProgressBar.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import SwiftUI

struct AccountCreationProgressBar: View {

    @Binding var page: Int

    var body: some View {
        HStack {
            ForEach(0..<AccountCreationHomeScreen.stepCount, id: \.self) { num in
                RoundedRectangle(cornerRadius: 2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 4)
                    .foregroundColor(num > page ? .secondary : Color.darkColor)
                    .onTapGesture {
                        page = num
                    }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    AccountCreationProgressBar(page: .constant(2))
}
