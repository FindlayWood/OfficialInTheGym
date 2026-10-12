//
//  ProPaywallLinks.swift
//  InTheGym
//
//  Created by Findlay Wood on 11/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//

import Foundation

/// The legal links an auto-renewing subscription's paywall must carry (App Review guideline
/// 3.1.2): Terms of Use and a Privacy Policy, both working links, in the app itself.
///
/// `termsOfUse` is Apple's standard EULA, which applies when App Store Connect has no custom
/// licence agreement. **`privacyPolicy` is `nil` until the app has one** — there is no privacy
/// policy URL anywhere in this repository — and the footer leaves the link out while it is. Set it
/// to the same URL as App Store Connect's App Privacy page before submitting: a subscription
/// paywall without one is rejected.
enum ProPaywallLinks {
    static let termsOfUse = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!
    static let privacyPolicy: URL? = nil
}
