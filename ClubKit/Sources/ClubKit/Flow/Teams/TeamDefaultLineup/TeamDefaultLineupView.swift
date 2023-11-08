//
//  SwiftUIView.swift
//  
//
//  Created by Findlay-Personal on 07/06/2023.
//

import SwiftUI

struct TeamDefaultLineupView: View {
    
    @ObservedObject var viewModel: TeamDefaultLineupViewModel
    
    var body: some View {
        List {
            if viewModel.team.defaultLineup == nil {
                Section {
                    Text("This team has no Default Lineup. Add it now!")
                }
            }
            Section {
                ForEach(0..<viewModel.team.sport.starters, id: \.self) { number in
                    HStack {
                        Text("\(number + 1).")
                        Spacer()
                        if viewModel.isEditing {
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color(.darkColour))
                            }
                        }
                    }
                }
            } header: {
                Text("Starters")
            }
            
            Section {
                ForEach(0..<viewModel.team.sport.subs, id: \.self) { number in
                    HStack {
                        Text("\(number + viewModel.team.sport.starters + 1).")
                        Spacer()
                        if viewModel.isEditing {
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color(.darkColour))
                            }
                        }
                    }
                }
            } header: {
                Text("Subs")
            }
            
            if viewModel.isEditing {
                Section {
                    Button {
                        viewModel.isEditing = false
                    } label: {
                        Text("Submit Lineup")
                            .padding()
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color(.darkColour))
                            .clipShape(Capsule())
                            .shadow(radius: 2, y: 2)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
    }
}

struct TeamDefaultLineupView_Previews: PreviewProvider {
    static var previews: some View {
        TeamDefaultLineupView(viewModel: TeamDefaultLineupViewModel(team: .example))
    }
}
