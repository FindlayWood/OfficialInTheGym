//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import SwiftUI

struct SetsSelectionView: View {
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Text("Sets")
                .font(.largeTitle.bold())
            HStack {
                Spacer()
                Button {
                    viewModel.sets -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
                Text(viewModel.sets, format: .number)
                    .font(.largeTitle.bold())
                Spacer()
                Button {
                    viewModel.sets += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color(.darkColour))
                }
                Spacer()
            }
            Text("Select the number of sets for this exercise.")
                .font(.footnote.bold())
                .foregroundColor(.secondary)
            
            Spacer()
            
            ScrollViewReader { value in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1..<100) { number in
                            Button {
                                viewModel.sets = number
                            } label: {
                                Text(number, format: .number)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(viewModel.sets == number ? Color(.darkColour) : Color(.lightColour))
                                    .clipShape(Circle())
                                    .id(number)
                            }
                            
                        }
                    }
                    .padding()
                }
                .animation(.easeInOut, value: viewModel.sets)
                .onChange(of: viewModel.sets) { newValue in
                    withAnimation {
                        value.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}

struct SetsSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        SetsSelectionView(viewModel: ExerciseCreationHomeViewModel(workoutCreation: PreviewWorkoutCreation()))
    }
}
