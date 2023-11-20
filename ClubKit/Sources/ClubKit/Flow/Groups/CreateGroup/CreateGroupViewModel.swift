//
//  File.swift
//  
//
//  Created by Findlay Wood on 20/11/2023.
//

import Foundation

class CreateGroupViewModel: ObservableObject {
    
    @Published var groupName: String = ""
    
    @Published var isUploading: Bool = false
    @Published var uploaded: Bool = false
    @Published var errorUploading: Bool = false
    
    var buttonDisabled: Bool {
        groupName.isEmpty 
    }
    
    let clubModel: RemoteClubModel
    
    init(clubModel: RemoteClubModel) {
        self.clubModel = clubModel
    }
    
    func create() {
        
    }
}
