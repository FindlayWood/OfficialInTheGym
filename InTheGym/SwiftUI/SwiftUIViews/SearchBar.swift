//
//  SearchBar.swift
//  InTheGym
//
//  Created by Findlay-Personal on 25/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(.secondarySystemBackground))
            HStack {
                Image(systemName: "magnifyingglass")
                TextField(placeholder, text: $searchText)
                    .foregroundColor(.primary)
                    .tint(Color(.darkColour))
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
            .foregroundColor(.gray)
            .padding(.leading, 13)
        }
        .frame(height: 40)
        .cornerRadius(13)
        .padding()
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""), placeholder: "search")
    }
}
