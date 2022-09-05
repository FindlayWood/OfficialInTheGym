//
//  WellnessStatusRowView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct WellnessStatusRowView: View {
    var model: WellnessAnswersModel
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(model.time, format: .dateTime.day().month().year())
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            VStack {
                Text(model.status.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.primary)
                Text("Status")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            HStack {
                Spacer()
                VStack {
                    Text(getSleepScore())
                        .font(.body.bold())
                    Text("Sleep")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text(returnQuality(from: model.bodyFeeling))
                        .font(.body.bold())
                    Text("Physical")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack {
                    Text(getAverageMental())
                        .font(.body.bold())
                    Text("Mental")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
    }
    
    func getSleepScore() -> String {
        let q = model.sleepQuality * 2
        let total = Double(q) + model.sleepAmount
        let avg = Int(total/2)
        return returnQuality(from: avg)
    }
    
    func getAverageMental() -> String {
        let total = model.mindFeeling + model.motivationFeeling + model.happyFeeling
        let avg = total / 3
        return returnQuality(from: avg)
    }
    
    func returnQuality(from score: Int) -> String {
        if score > 9 {
            return "Excellent"
        } else if score > 7 {
            return "Very Good"
        } else if score > 5 {
            return "Good"
        } else if score > 3 {
            return "Ok"
        } else if score > 1 {
            return "Poor"
        } else {
            return "Very Poor"
        }
    }
}

//struct WellnessStatusRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        WellnessStatusRowView(model: .init(score: 7, time: Date()))
//    }
//}
