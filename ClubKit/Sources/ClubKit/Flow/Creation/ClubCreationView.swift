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
        NavigationStack {
            List {
                Section {
                    VStack {
                        Text("Create a new club")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                }
                Section {
                    TextField("Display Name", text: $viewModel.displayName)
                }
                Section {
                    TextField("Tag Line", text: $viewModel.tagline)
                }
                Section {
                    Button {
                        
                    } label: {
                        Text("Create Club")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Club Creation")
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
