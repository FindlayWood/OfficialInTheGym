//
//  SavedWorkoutSheet.swift
//  InTheGym
//
//  Created by Findlay-Personal on 26/11/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct SavedWorkoutSheet: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel = ViewModel()
    var selection: (SavedWorkoutModel) -> ()
    var body: some View {
        NavigationView {
            List {
                if !viewModel.isLoading && viewModel.savedWorkouts.isEmpty {
                    Section {
                        Text("You don't have any saved workouts.")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.clear)
                }
                Section {
                    ForEach(viewModel.savedWorkouts, id: \.id) { model in
                        Button {
                            selection(model)
                            dismiss()
                        } label: {
                            SavedWorkoutListView(model: model)
                        }
                        .buttonStyle(.borderless)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                    }
                } header: {
                    Text("Your Saved Workouts")
                }
            }
            .navigationTitle("Saved Workouts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("dismiss")
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.darkColour))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.isLoading {
                        ProgressView()
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
            .task {
                await viewModel.fetchKeys()
            }
            .onAppear {
                //Use this if NavigationBarTitle is with displayMode = .inline
                UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.darkColour]
            }
        }
    }
}

extension SavedWorkoutSheet {
    @MainActor final class ViewModel: ObservableObject {
        // MARK: - Published
        @Published var isLoading: Bool = false
        @Published var savedWorkouts: [SavedWorkoutModel] = []
        
        // MARK: - Properties
        var apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared
        
        // MARK: - Initializer
        init(apiService: FirebaseDatabaseManagerService = FirebaseDatabaseManager.shared) {
            self.apiService = apiService
        }
        
        // MARK: - Methods
        func fetchKeys() async {
            isLoading = true
            let savedWorkoutSearchModel = SavedWorkoutsReferences(id: UserDefaults.currentUser.uid)
            do {
                let keys: [String] = try await apiService.fetchKeysAsync(from: savedWorkoutSearchModel)
                await fetchModels(keys)
            } catch {
                print(String(describing: error))
            }
        }
        
        func fetchModels(_ keys: [String]) async {
            let savedKeysModel = keys.map { SavedWorkoutKeyModel(id: $0) }
            do {
                let models: [SavedWorkoutModel] = try await apiService.fetchRangeAsync(from: savedKeysModel)
                savedWorkouts = models
                isLoading = false
            } catch {
                print(String(describing: error))
            }
        }
    }
}
