//
//  SelectOptionSheet.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/01/2026.
//

import SwiftUI

struct SelectOptionSheet: View {
    
    var exerciseSelected: (() -> ())?
    var fitnessSelected: (() -> ())?
    var sportSelected: (() -> ())?
    
    var body: some View {
        VStack {
            Text("Select Option")
                .font(.largeTitle)
                .padding(.top)
            
            
            Spacer()
            
            Button {
                exerciseSelected?()
            } label: {
                Text("Exercise")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        Color
                            .blue
                            .clipShape(Capsule())
                    }
            }
            
            Button {
                fitnessSelected?()
            } label: {
                Text("Fitness")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        Color
                            .blue
                            .clipShape(Capsule())
                    }
            }
            
            Button {
                sportSelected?()
            } label: {
                Text("Sport")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background {
                        Color
                            .blue
                            .clipShape(Capsule())
                    }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SelectOptionSheet()
}
