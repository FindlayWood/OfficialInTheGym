//
//  DiscoverSearchBar.swift
//  InTheGym
//
//  Created by Findlay-Personal on 19/02/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct DiscoverSearchBar: View {
    
    @Binding var searchText: String
    var placeholder: String
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(.secondarySystemBackground))
            
            HStack {
                TextField(placeholder, text: $searchText)
                    .foregroundColor(.primary)
                    .tint(Color(.darkColour))
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 40)
        .clipShape(Capsule())
        .padding()
    }
}

struct DiscoverSearchBar_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverSearchBar(searchText: .constant(""), placeholder: "search...")
    }
}
