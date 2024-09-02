//
//  File.swift
//  
//
//  Created by Findlay Wood on 24/11/2023.
//

import Foundation

class StaffListViewModel: ObservableObject {
    
    @Published var errorLoading: Error?
    @Published var staff: [RemoteStaffModel] = []
    @Published var selectedStaffModels: [RemoteStaffModel] = []
    @Published var isLoading: Bool = false
    
    @Published var searchText: String = ""
    
    var searchedStaff: [RemoteStaffModel] {
        if searchText.isEmpty {
            return staff
        } else {
            return staff.filter { $0.displayName.lowercased().contains(searchText.lowercased())
                || $0.role.rawValue.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var excludedStaff: [RemoteStaffModel] = []
    
    var clubModel: RemoteClubModel
    var staffLoader: StaffLoader
    let selectable: Bool
    
    var selectedStaffAction: ((RemoteStaffModel) -> ())?
    var selectedStaffConfirmed: (([RemoteStaffModel]) -> ())?
    
    init(clubModel: RemoteClubModel, staffLoader: StaffLoader, selectable: Bool = false) {
        self.clubModel = clubModel
        self.staffLoader = staffLoader
        self.selectable = selectable
    }
    
    func loadFromClub() {
        Task { @MainActor in
            isLoading = true
            do {
                staff = try await staffLoader.loadAllStaff(for: clubModel.id).filter(checkForExclusion)
                isLoading = false
            } catch {
                errorLoading = error
                print(String(describing: error))
                isLoading = false
            }
        }
    }
    
    func checkForExclusion(_ model: RemoteStaffModel) -> Bool {
        !(excludedStaff.contains(where: { $0.id == model.id }))
    }
    
    func toggleSelection(of model: RemoteStaffModel) {
        if selectedStaffModels.contains(where: { $0 == model }) {
            selectedStaffModels.removeAll(where: { $0 == model })
        } else {
            selectedStaffModels.append(model)
        }
    }
    
    func checkSelection(of model: RemoteStaffModel) -> Bool {
        selectedStaffModels.contains(model)
    }
    
    func confirmSelectionAction() {
        selectedStaffConfirmed?(selectedStaffModels)
    }
    
    func tappedOn(_ model: RemoteStaffModel) {
        selectable ? toggleSelection(of: model) : selectedStaffAction?(model)
    }
    
}
