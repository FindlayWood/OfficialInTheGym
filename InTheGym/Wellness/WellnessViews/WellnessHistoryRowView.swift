//
//  WellnessHistoryRowView.swift
//  InTheGym
//
//  Created by Findlay Wood on 28/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WellnessHistoryRowView: View {
    var model: WellnessAnswersModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.time, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(model.status.title)
                    .font(.headline)
            }
            Spacer()
        }
    }
}
