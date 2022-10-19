//
//  MatchTrackerDetailView.swift
//  InTheGym
//
//  Created by Findlay Wood on 19/10/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct MatchTrackerDetailView: View {
    var model: MatchTrackerModel
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(model.overallRating, format: .number)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(.darkColour))
                Spacer()
            }
            
        }
    }
}
