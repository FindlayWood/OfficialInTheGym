//
//  ClubCreationView.swift
//  
//
//  Created by Findlay-Personal on 14/05/2023.
//

import SwiftUI

struct ClubCreationView: View {
    
    @ObservedObject var viewModel: ClubCreationViewModel
    
    var body: some View {
        VStack {
            TextField("Display Name", text: $viewModel.displayName)
            TextField("Tag Line", text: $viewModel.tagline)
        }
    }
}

struct ClubCreationView_Previews: PreviewProvider {
    private struct PreviewService: CreationService {
        func createNewClub(with data: NewClubData) async -> Result<NewClubData, RemoteCreationService.Error> {
            return .failure(.failed)
        }
    }
    static var previews: some View {
        ClubCreationView(viewModel: ClubCreationViewModel(service: PreviewService()))
    }
}
