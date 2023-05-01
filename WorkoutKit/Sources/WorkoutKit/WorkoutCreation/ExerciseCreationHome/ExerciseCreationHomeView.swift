//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 23/04/2023.
//

import SwiftUI

struct ExerciseCreationHomeView: View {
    @ObservedObject var viewModel: ExerciseCreationHomeViewModel
    
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<4) { num in
                    RoundedRectangle(cornerRadius: 2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .foregroundColor(num > viewModel.page ? .secondary : Color(.darkColour))
                        .onTapGesture {
                            viewModel.page = num
                        }
                        .disabled(viewModel.page == 0)
                }
            }
            .padding(.horizontal)
            
            TabView(selection: $viewModel.page) {
                ExerciseSelectionView(viewModel: viewModel)
                    .tag(0)
                    .contentShape(Rectangle()).gesture(DragGesture())
                SetsSelectionView(viewModel: viewModel)
                    .tag(1)
                RepsSelectionView(viewModel: viewModel)
                    .tag(2)
                UnitsSelectionView(viewModel: viewModel)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                if viewModel.page > 0 {
                    Button {
                        viewModel.page -= 1
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "chevron.left")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
                
                if viewModel.page > 0 && viewModel.page < 3 {
                    Button {
                        viewModel.page += 1
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 60, height: 60)
                                .foregroundColor(Color(.darkColour))
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                }
                if viewModel.page == 3 {
                    Button {
                        viewModel.addExerciseAction()
                    } label: {
                        Text("Add Exercise")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                            .shadow(radius: 4)
                    }
                }
            }
            .padding()

        }
    }
}

struct ExerciseCreationHomeView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseCreationHomeView(viewModel: ExerciseCreationHomeViewModel(workoutViewModel: WorkoutCreationHomeViewModel()))
    }
}
