//
//  ExerciseMuscleGroup.swift
//  MyDayKit
//
//  Created by Findlay Wood on 25/10/2026.
//

import Foundation

/// One entry of the `MuscleGroups` collection, as the custom exercise form
/// offers it: `chest` → "Chest".
///
/// **The id is what is stored; `name` is only ever shown.** An exercise's
/// `muscleGroups` holds ids, and the DailyTotals function keys training balance
/// by them, so a screen never prettifies an id itself — it looks the name up
/// here.
///
/// `category` is the region the group belongs to, in `ExerciseCategory`'s raw
/// values, so the form can group the chips. It decodes leniently: a region the
/// app does not know reads as `nil` rather than dropping the muscle group from
/// the form, where a missing chip is an answer the user cannot give.
public struct ExerciseMuscleGroup: Codable, Hashable, Identifiable {
    public let id: String
    public let name: String
    public let category: ExerciseCategory?

    public init(id: String, name: String, category: ExerciseCategory?) {
        self.id = id
        self.name = name
        self.category = category
    }

    enum CodingKeys: String, CodingKey {
        case id, name, category
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try? container.decodeIfPresent(ExerciseCategory.self, forKey: .category)
    }
}
