//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 11/04/2023.
//

import SwiftUI

struct BioView: View {
    @ObservedObject var viewModel: AccountCreationHomeViewModel
    @State private var placeholder: String = "write something about you..."
    var colour: UIColor
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Bio")
                .font(.title.bold())
                .foregroundColor(.primary)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $placeholder)
                    .foregroundColor(.secondary)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
                TextEditor(text: $viewModel.bio)
                    .frame(maxHeight: 300)
                    .cornerRadius(8)
                    .opacity(viewModel.bio.isEmpty ? 0.3 : 1)
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

struct BioView_Previews: PreviewProvider {
    static var previews: some View {
        BioView(viewModel: AccountCreationHomeViewModel(email: "", uid: ""), colour: .blue)
    }
}
