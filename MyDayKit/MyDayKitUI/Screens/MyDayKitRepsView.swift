//
//  MyDayKitRepsView.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/08/2025.
//

import SwiftUI

struct MyDayKitRepsView: View {
    
    @ObservedObject var dayManager: MyDayManager
    
    let exercise: MyDayNewExerciseManager
    @State var reps: Int = 1
    
    var add: (() -> ())?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How many reps did you complete?")
                .font(.headline)
                .padding()
            
            Text(exercise.exercise.name)
                .font(.title2)
                .bold()
            
            Spacer()
            
            HStack {
                Spacer()
                Button {
                    guard reps > 0 else { return }
                    reps -= 1
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .opacity(reps > 0 ? 1 : 0.3)
                }
                .disabled(reps < 2)
                Spacer()
                Text("\(reps)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Spacer()
                Button {
                    guard reps < 99 else { return }
                    reps += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .opacity(reps < 99 ? 1 : 0.3)
                }
                .disabled(reps > 98)
                Spacer()
            }
            .padding(.horizontal)
            
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(1..<100, id: \.self) { num in
                            Button {
                                reps = num
                                withAnimation {
                                    proxy.scrollTo("\(num)", anchor: .center)
                                }
                            } label: {
                                Text("\(num)")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(num == reps ? Color.white : Color.black.opacity(0.5))
                                    .frame(width: 80, height: 80)
                                    .background {
                                        Circle()
                                            .foregroundStyle(Color.blue.opacity(num == reps ? 1 : 0.3))
                                    }
                                    .overlay {
                                        Circle()
                                            .inset(by: 1)
                                            .stroke(Color.black, lineWidth: 1)
                                    }
                            }
                            .padding(.vertical)
                            .id("\(num)")
                        }
                    }
                    .padding(.leading)
                }
                .onChange(of: reps) { _, newValue in
                    withAnimation {
                        proxy.scrollTo("\(newValue)", anchor: .center)
                    }
                }
            }

            Spacer()
            
            Button {
                addAction()
            } label: {
                Text("Add")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.blue
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
            }
            .padding()
        }
    }
    
    func addAction() {
        exercise.setReps(reps)
        add?()
    }
}

#Preview {
    MyDayKitRepsView(dayManager: MyDayManager(saver: PreviewSaver(), loader: PreviewLoader()), exercise: MyDayNewExerciseManager(exercise: .pressUps))
}
