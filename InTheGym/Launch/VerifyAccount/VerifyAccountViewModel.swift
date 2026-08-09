//
//  VerifyAccountViewModel.swift
//  InTheGym
//
//  Created by Findlay-Personal on 07/04/2023.
//  Copyright © 2023 FindlayWood. All rights reserved.
//

import UIKit
import Firebase

class VerifyAccountViewModel: ObservableObject {

    @Published var user: User?

    /// Mirrored off the Firebase user so the view never touches the `User` type — it only ever
    /// needed the address to show.
    @Published var email: String?

    @Published var resendState: VerifyEmailResendState = .idle

    var baseFlow: BaseFlow?
    var apiService: AuthManagerService
    var signOutAction: (() -> Void)?

    /// Seconds the resend button stays disabled after a successful send. Firebase rate-limits
    /// verification emails, so the cooldown is as much about not producing an error as it is about
    /// stopping people mashing the button while they wait for a mail to arrive.
    static let resendCooldown: Int = 30

    init(apiService: AuthManagerService = FirebaseAuthManager.shared) {
        self.apiService = apiService
        user = Auth.auth().currentUser
        email = user?.email
        initTimer()
    }

    deinit {
        timer?.invalidate()
        cooldownTimer?.invalidate()
    }

    // MARK: - Polling

    private var timer: Timer?
    private var cooldownTimer: Timer?

    func initTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { [weak self] _ in
            self?.verifiedEmailAction()
        })
    }

    func verifiedEmailAction() {
        guard let user else { return }
        Task {
            do {
                try await user.reload()
                if user.isEmailVerified {
                    await MainActor.run {
                        // Stop polling before moving on. The timer is retained by the run loop, so
                        // without this it keeps calling `reload()` every two seconds for the rest of
                        // the session, long after this screen is gone.
                        self.timer?.invalidate()
                        self.timer = nil
                        self.goToAccountCreation()
                    }
                }
            } catch {
                print(String(describing: error))
            }
        }
    }

    // MARK: - Resend

    @MainActor
    func resendVerificationEmailAction() {
        guard resendState == .idle || resendState == .failed else { return }
        resendState = .sending
        Task {
            do {
                try await apiService.sendEmailVerification()
                resendState = .sent(secondsRemaining: Self.resendCooldown)
                startCooldown()
            } catch {
                print(String(describing: error))
                resendState = .failed
            }
        }
    }

    private func startCooldown() {
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            guard case .sent(let remaining) = self.resendState else {
                timer.invalidate()
                return
            }
            if remaining <= 1 {
                timer.invalidate()
                self.cooldownTimer = nil
                self.resendState = .idle
            } else {
                self.resendState = .sent(secondsRemaining: remaining - 1)
            }
        }
    }

    // MARK: - Navigation

    func logoutAction() {
        do {
            try apiService.signout()
            signOutAction?()
        } catch {
            print(String(describing: error))
        }
    }

    func goToAccountCreation() {
        guard let email = user?.email,
              let uid = user?.uid
        else {
            return
        }
        baseFlow?.showAccountCreation(email: email, uid: uid)
    }
}
