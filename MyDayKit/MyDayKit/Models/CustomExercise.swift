//
//  CustomExercise.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// An exercise a user made because the catalogue lacked it, as it is stored at
/// `Users/{uid}/CustomExercises/{id}`, at the top-level `CustomExercises/{id}`
/// for review, and on disk.
///
/// **Every catalogue field is required.** Name, category, muscle groups,
/// movement patterns, compound and unilateral are what a catalogue exercise
/// has, so approving one writes `Exercises/{id}` with nothing left to fill in.
/// A custom exercise is complete or it is not saved — which is why these are
/// non-optional here while the same fields are optional on `Exercise`, whose
/// day files predate them.
///
/// **The id is a plain UUID and approval keeps it.** Every raw log, template
/// and day file the creator wrote already points at it, so once the catalogue
/// holds the same id their history is catalogue history with nothing migrated.
/// Do not prefix it: the server tells custom from catalogue by where the
/// document is, not by its id.
///
/// **The name never changes after saving.** Raw logs, templates and
/// `ExerciseStats` each store the name they were written with, and a rename
/// would split one exercise's history across two names. `name` is a `let` for
/// that reason; the other body fields may be edited while the exercise is in
/// review.
public struct CustomExercise: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public var category: ExerciseCategory
    /// Ids from `MuscleGroups`, at least one.
    public var muscleGroups: [String]
    /// Ids from `MovementTypes`, at least one.
    public var movementPatterns: [String]
    public var isCompound: Bool
    public var isUnilateral: Bool
    /// The creator — the signed-in user, injected, never read off anything else.
    public let createdBy: String
    public let createdAt: Date
    public var updatedAt: Date
    /// Set when the creator deletes it. Delete is an archive: it leaves the
    /// picker, but logs, templates and stats keep the id.
    public var archivedAt: Date?
    /// The server's; `nil` until it has mirrored one. Never encoded.
    public private(set) var status: CustomExerciseStatus?

    public init(
        id: String = UUID().uuidString,
        name: String,
        category: ExerciseCategory,
        muscleGroups: [String],
        movementPatterns: [String],
        isCompound: Bool,
        isUnilateral: Bool,
        createdBy: String,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        archivedAt: Date? = nil,
        status: CustomExerciseStatus? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.muscleGroups = muscleGroups
        self.movementPatterns = movementPatterns
        self.isCompound = isCompound
        self.isUnilateral = isUnilateral
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
        self.status = status
    }

    /// The exercise as the picker offers it and as a log embeds it.
    var exercise: Exercise {
        Exercise(
            id: id,
            name: name,
            category: category,
            muscleGroups: muscleGroups,
            movementPatterns: movementPatterns,
            isCompound: isCompound,
            isUnilateral: isUnilateral
        )
    }
}

// MARK: - Codable
extension CustomExercise {

    enum CodingKeys: String, CodingKey {
        case id, name, category, muscleGroups, movementPatterns, isCompound, isUnilateral
        case createdBy, createdAt, updatedAt, archivedAt, status
    }

    /// `status` decodes leniently: a state the server adds later reads as no
    /// status rather than failing the document, which would drop the exercise
    /// from the creator's picker.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(ExerciseCategory.self, forKey: .category)
        muscleGroups = try container.decode([String].self, forKey: .muscleGroups)
        movementPatterns = try container.decode([String].self, forKey: .movementPatterns)
        isCompound = try container.decode(Bool.self, forKey: .isCompound)
        isUnilateral = try container.decode(Bool.self, forKey: .isUnilateral)
        createdBy = try container.decode(String.self, forKey: .createdBy)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        archivedAt = try container.decodeIfPresent(Date.self, forKey: .archivedAt)
        status = try? container.decodeIfPresent(CustomExerciseStatus.self, forKey: .status)
    }

    /// **`status` is never encoded.** Only the server writes it, and a client
    /// write carrying one — even the value it read — would be rejected by the
    /// rules or, worse, put back a status the review has since changed.
    /// Writers must therefore merge, so the server's field survives.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(muscleGroups, forKey: .muscleGroups)
        try container.encode(movementPatterns, forKey: .movementPatterns)
        try container.encode(isCompound, forKey: .isCompound)
        try container.encode(isUnilateral, forKey: .isUnilateral)
        try container.encode(createdBy, forKey: .createdBy)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(archivedAt, forKey: .archivedAt)
    }
}
