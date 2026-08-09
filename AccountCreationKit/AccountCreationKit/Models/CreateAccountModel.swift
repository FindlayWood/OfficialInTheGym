//
//  CreateAccountModel.swift
//  AccountCreationKit
//
//  Created by Findlay Wood on 09/08/2026.
//

import Foundation

/// The account the user has assembled across the creation steps.
///
/// How this is written — the callable function's name, the shape of its payload — belongs to the
/// composition root, not here. See `AccountCreator`.
public struct CreateAccountModel: Codable {
    public var uid: String
    public var email: String
    public var username: String
    public var displayName: String
    public var bio: String

    /// Always `.individual` for anything created now: the flow stopped asking, because the answer
    /// changed nothing the user could see. The field stays because `Users.accountType` is
    /// non-optional and every existing document carries one — see the Firestore decode warning under
    /// Workout Library Loading in CLAUDE.md.
    public var accountType: AccountType

    // MARK: - Body

    /// Stored in centimetres and kilograms whatever the user entered them in, so two people's
    /// numbers can be compared without unpicking a unit first. The units below record how to read
    /// them back, not what they mean.
    public var heightCentimetres: Double?
    public var weightKilograms: Double?
    public var heightUnit: HeightUnit?
    public var weightUnit: BodyWeightUnit?

    /// Date of birth rather than an age, so it does not quietly go stale.
    public var dateOfBirth: Date?

    public var createdDate: Date
    public var verifiedAccount: Bool
    public var eliteAccount: Bool
    public var isPrivate: Bool

    public init(
        uid: String,
        email: String,
        username: String,
        displayName: String,
        bio: String,
        accountType: AccountType = .individual,
        heightCentimetres: Double? = nil,
        weightKilograms: Double? = nil,
        heightUnit: HeightUnit? = nil,
        weightUnit: BodyWeightUnit? = nil,
        dateOfBirth: Date? = nil,
        createdDate: Date = .now,
        verifiedAccount: Bool = false,
        eliteAccount: Bool = false,
        isPrivate: Bool = false
    ) {
        self.uid = uid
        self.email = email
        self.username = username
        self.displayName = displayName
        self.bio = bio
        self.accountType = accountType
        self.heightCentimetres = heightCentimetres
        self.weightKilograms = weightKilograms
        self.heightUnit = heightUnit
        self.weightUnit = weightUnit
        self.dateOfBirth = dateOfBirth
        self.createdDate = createdDate
        self.verifiedAccount = verifiedAccount
        self.eliteAccount = eliteAccount
        self.isPrivate = isPrivate
    }
}
