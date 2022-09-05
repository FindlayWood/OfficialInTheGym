//
//  MyMeasurementsView.swift
//  InTheGym
//
//  Created by Findlay Wood on 27/06/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import SwiftUI

struct MyMeasurementsView: View {
    
    @ObservedObject var viewModel: MyMeasurementsViewModel
    
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        viewModel.cancel()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(.darkColour))
                    }
                    Spacer()
                    Button {
                        withAnimation {
                            viewModel.showingPopover = true
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.bold)
                            .foregroundColor(viewModel.validUploadState ? Color(.darkColour) : .gray.opacity(0.6))
                    }
                    .disabled(!viewModel.validUploadState)
                }
                .padding()
                Form {
                    Section {
                        MeasurementSubview(placeholder: "Height", units: "cm", enteredText: $viewModel.height)
                    } header: {
                        Text("height")
                    }
                    Section {
                        MeasurementSubview(placeholder: "Weight", units: "kg", enteredText: $viewModel.weight)
                    } header: {
                        Text("weight")
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .task {
                await viewModel.loadMeasurements()
            }
            if viewModel.showingPopover {
                PrivacyPopupView(viewModel: viewModel, isPrivate: $viewModel.isPrivate)
            }
            if viewModel.error != nil {
                ErrorPopover(viewModel: viewModel)
            }
            if viewModel.isLoading {
                LoadingView()
            }
        }
    }
}

//struct MyMeasurementsView_Previews: PreviewProvider {
//    static var previews: some View {
//        MyMeasurementsView()
//    }
//}
