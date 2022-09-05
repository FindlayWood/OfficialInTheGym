//
//  ExerciseTempoModel.swift
//  InTheGym
//
//  Created by Findlay Wood on 29/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

struct ExerciseTempoModel: Codable, Hashable {
    /// model to represent tempo
    var eccentric: Int /// the eccentric phase in seconds - lowering
    var eccentricPause: Int /// the pause after eccentric in seconds
    var concentric: Int /// the concentric phase in seconds - lifting
    var concentricPause: Int /// the pause after the concentric phase in seconds
    
    var generatedString: String {
        "\(eccentric)-\(eccentricPause)-\(concentric)-\(concentricPause)"
    }
}
