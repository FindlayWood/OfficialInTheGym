//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 29/04/2023.
//

import SwiftUI

struct OptionsSheet: View {
    @ObservedObject var viewModel: WorkoutCreationHomeViewModel
    @State private var isShowingTag: Bool = false
    var body: some View {
        VStack {
            HStack {
                Text("Options")
                    .font(.title.bold())
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding()
            Toggle(isOn: $viewModel.isPrivate) {
                VStack {
                    Text("Private")
                        .font(.headline)
                    Text("Do you want this workout to be private?")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }
            Toggle(isOn: $viewModel.isSaving) {
                VStack {
                    Text("Saving")
                        .font(.headline)
                    Text("Do you want to save this workout?")
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                }
            }
            ZStack(alignment: .bottomTrailing) {
                if viewModel.tags.isEmpty {
                    VStack {
                        ZStack {
                            Image(systemName: "tag.fill")
                                .font(.largeTitle)
                                .foregroundColor(Color(.darkColour).opacity(0.6))
                            Image(systemName: "nosign")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.red.opacity(0.5))
                        }
                        Text("No Tags")
                            .font(.title.bold())
                            .foregroundColor(Color(.darkColour))
                        Text("You have no tags for this workout. Tags help people search for workouts and could include the body part the workout targets, the kind of workout it is, how often to perform the workout etc")
                            .font(.footnote.bold())
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button {
                            isShowingTag.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(Color(.darkColour))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.secondarySystemBackground))
                } else {
                    List {
                        Section {
                            ForEach(viewModel.tags) { model in
                                HStack {
                                    Text("#\(model.tag)")
                                        .font(.headline)
                                        .padding()
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemBackground))
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1))
                            }
                        } header: {
                            Text("Tags")
                        }
                    }
                }
                if !viewModel.tags.isEmpty {
                    Button {
                        isShowingTag.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(Color(.darkColour))
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $isShowingTag) {
            TagSheet(currentTags: viewModel.tags) { viewModel.addTag($0) }
            .presentationDragIndicator(.visible)
        }
    }
}

struct OptionsSheet_Previews: PreviewProvider {
    static var previews: some View {
        OptionsSheet(viewModel: WorkoutCreationHomeViewModel())
    }
}
