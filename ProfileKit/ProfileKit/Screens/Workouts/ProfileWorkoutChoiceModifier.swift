//
//  ProfileWorkoutChoiceModifier.swift
//  ProfileKit
//
//  Created by Findlay Wood on 12/11/2026.
//

import SwiftUI

/// Draws `ProfileWorkoutChoiceCard` over a screen while its opener holds a choice: a 0.4 black dim
/// that dismisses on tap, the card centred on it.
///
/// Presented from `.overlay { }`, as MyDay's dialogs are. On a screen pushed with the system bar
/// (`UserProfileScreen`, the workout lists) the dim cannot reach over that bar, which belongs to
/// the navigation controller. The card is still centred and fully usable.
struct ProfileWorkoutChoiceModifier: ViewModifier {

    @ObservedObject var opener: ProfileWorkoutOpener

    func body(content: Content) -> some View {
        content
            .overlay {
                if let choice = opener.choice {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture { opener.dismissChoice() }
                        ProfileWorkoutChoiceCard(
                            title: choice.title,
                            onOpenWorkout: { opener.chooseWorkout() },
                            onViewOnDiscover: { opener.chooseDiscover() },
                            onCancel: { opener.dismissChoice() }
                        )
                        .padding(.horizontal, 24)
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: opener.choice?.id)
    }
}

extension View {
    func profileWorkoutChoice(_ opener: ProfileWorkoutOpener) -> some View {
        modifier(ProfileWorkoutChoiceModifier(opener: opener))
    }
}
