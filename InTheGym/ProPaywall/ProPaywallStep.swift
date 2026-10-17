//
//  ProPaywallStep.swift
//  InTheGym
//
//  Created by Findlay Wood on 12/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// Where the paywall flow is: choosing a plan, asking to send the trial reminder, or done.
///
/// The reminder step exists **only after a trial has started**, and only when notifications are not
/// already allowed — someone who allowed them earlier gets the reminder scheduled without being
/// asked. It used to be a toggle on the paywall, which could not ask for permission at a sensible
/// moment: the app asked at first launch instead, before the user had any reason to say yes.
enum ProPaywallStep: Equatable {
    case paywall
    case trialReminder(StartedTrial, TrialReminderPermission)
    /// `trial` is nil for a plan with no trial, a restore, or an account that already had pro.
    case success(trial: StartedTrial?, isReminded: Bool)
}
