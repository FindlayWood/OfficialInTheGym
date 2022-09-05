//
//  UpdateTrainingStatusView.swift
//  InTheGym
//
//  Created by Findlay Wood on 07/08/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct UpdateTrainingStatusView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentStatus: AthleteStatus
    @ObservedObject var viewModel: TrainingStatusViewModel
    var body: some View {
        NavigationView {
            List {
                ForEach(AthleteStatus.allCases, id: \.self) { status in
                    Section {
                        TrainingStatusRowView(status: status)
                            .onTapGesture {
                                currentStatus = status
                                viewModel.changeStatus(status)
                                dismiss()
                            }
                    }
                }
            }
            .navigationTitle("Update Training Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundColor(Color(.darkColour))
                    }
                }
            }
        }
    }
}

struct UpdateTrainingStatusView_Previews: PreviewProvider {
    static var previews: some View {
        UpdateTrainingStatusView(currentStatus: .constant(.inSeason), viewModel: TrainingStatusViewModel())
    }
}


struct TrainingStatusRowView: View {
    var status: AthleteStatus
    var body: some View {
        HStack(spacing: 8) {
            Image(uiImage: status.icon!)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Text(status.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text(status.message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
        }
        .padding()
    }
}
