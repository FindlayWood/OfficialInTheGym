//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 22/05/2023.
//

import SwiftUI

struct CreatePlayerView: View {
    
    @ObservedObject var viewModel: CreatePlayerViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct CreatePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        CreatePlayerView(viewModel: CreatePlayerViewModel())
    }
}
