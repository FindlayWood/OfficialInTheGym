//
//  CoachRequestRow.swift
//  InTheGym
//
//  Created by Findlay-Personal on 19/03/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import SwiftUI

struct CoachRequestRow: View {
    @StateObject var viewModel = ViewModel()
    @State var cellModel: CoachRequestCellModel
    @Namespace var namespace
    
    var body: some View {
        HStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Circle()
                    .foregroundColor(.gray)
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text(cellModel.user.displayName)
                        .font(.custom("Menlo-Bold", size: 22, relativeTo: .title))
                        .foregroundColor(Color(.darkColour))
                    if cellModel.user.eliteAccount {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(.goldColour))
                    } else if cellModel.user.verifiedAccount {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(.lightColour))
                    }
                }
                Text("@\(cellModel.user.username)")
                    .font(.body.weight(.medium))
                    .foregroundColor(.gray)
                
                switch cellModel.requestStatus {
                case .accepted:
                    Text("Accepted")
                        .font(.headline)
                        .foregroundColor(Color(.darkColour))
                        .padding(.horizontal)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color(.darkColour), lineWidth: 2)
                        )
                        .padding(.vertical, 4)
                case .sent:
                    HStack {
                        Text("Sent")
                            .font(.headline)
                            .foregroundColor(Color(.darkColour))
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color(.darkColour), lineWidth: 2)
                            )
                            .padding(.vertical, 4)
                        Button {
                            withAnimation {
                                viewModel.isLoading = true
                            }
                            Task {
                                do {
                                    try await viewModel.unSendRequest(to: cellModel.user)
                                    cellModel.requestStatus = .none
                                    withAnimation {
                                        viewModel.isLoading = false
                                    }
                                } catch {
                                    withAnimation {
                                        viewModel.isLoading = false
                                    }
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color(.darkColour))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(.darkColour), lineWidth: 2)
                                    )
                                    .padding(.vertical, 4)
                            } else {
                                Text("Unsend")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .background(Color(.darkColour))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color(.darkColour), lineWidth: 2)
                                    )
                                    .padding(.vertical, 4)
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .matchedGeometryEffect(id: "darkButton", in: namespace)
                    }
                case.none:
                    Button {
                        withAnimation {
                            viewModel.isLoading = true
                        }
                        Task {
                            do {
                                try await viewModel.sendRequest(to: cellModel.user)
                                cellModel.requestStatus = .sent
                                viewModel.isLoading = false
                            } catch {
                                viewModel.isLoading = false
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.darkColour))
                                .cornerRadius(4)
                                .padding(.vertical, 4)
                        } else {
                            Text("Send Request")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color(.darkColour))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(Color(.darkColour), lineWidth: 2)
                                )
                                .padding(.vertical, 4)
                        }
                    }
                    .disabled(viewModel.isLoading)
                    .matchedGeometryEffect(id: "darkButton", in: namespace)
                }
            }
        }
        .onAppear {
            viewModel.getImage(for: cellModel.user)
        }
    }
}

extension CoachRequestRow {
    final class ViewModel: ObservableObject {
        // MARK: - Published Properties
        @Published var image: UIImage?
        @Published var isLoading: Bool = false
        
        var apiService: FirebaseDatabaseManagerService
        
        init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
            self.apiService = apiService
        }
        
        // MARK: - Methods
        func getImage(for user: Users) {
            let downloadModel = ProfileImageDownloadModel(id: user.uid)
            ImageCache.shared.load(from: downloadModel) { [weak self] result in
                guard let image = try? result.get() else {return}
                self?.image = image
            }
        }
        func sendRequest(to user: Users) async throws {
            let coachRequestModel = CoachRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
            let playerRequestModel = PlayerRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
            
            let uploadPoints: [FirebaseMultiUploadDataPoint] = [FirebaseMultiUploadDataPoint(value: true, path: coachRequestModel.internalPath), FirebaseMultiUploadDataPoint(value: true, path: playerRequestModel.internalPath)]
            
            try await apiService.multiLocationUploadAsync(data: uploadPoints)
        }
        func unSendRequest(to user: Users) async throws {
            let playerRequestModel = PlayerRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
            let coachRequestModel = CoachRequestUploadModel(playerID: user.uid, coachID: UserDefaults.currentUser.uid)
            let uploadPoints: [FirebaseMultiUploadDataPoint] = [
                FirebaseMultiUploadDataPoint(value: nil, path: playerRequestModel.internalPath),
                FirebaseMultiUploadDataPoint(value: nil, path: coachRequestModel.internalPath)
            ]
            
            try await apiService.multiLocationUploadAsync(data: uploadPoints)
        }
    }
}
