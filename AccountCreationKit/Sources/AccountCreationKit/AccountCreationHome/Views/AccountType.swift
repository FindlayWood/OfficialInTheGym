//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 09/04/2023.
//

import SwiftUI

struct AccountTypeView: View {
    
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    
    var colour: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Account Type")
                .font(.title.bold())
            ForEach(AccountType.allCases) { model in
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.title)
                            .font(.headline)
                        Text(model.message)
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: viewModel.selectedAccountType == model ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(Color(colour))
                }
                .padding()
                .background(viewModel.selectedAccountType == model ? Color(.systemBackground) : .clear)
                .overlay(RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(colour), lineWidth: 2))
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.selectedAccountType = model
                }
            }
            Text("Select which account type best suits you.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding()
    }
}

struct AccountTypeView_Previews: PreviewProvider {
    static var previews: some View {
        AccountTypeView(viewModel: AccountCreationHomeViewModel(email: "", uid: "", callback: {}, signOutCallback: {}), colour: .blue)
    }
}
