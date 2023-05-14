//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

struct ClubHomeView: View {
    
    @ObservedObject var viewModel: ClubHomeViewModel
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ClubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ClubHomeView(viewModel: ClubHomeViewModel(clubModel: .example))
    }
}
