//
//  InjuryRegion.swift
//  MyDayKit
//
//  Created by Findlay Wood on 10/11/2026.
//

import Foundation

/// Where an injury is. **A fixed list, never free text**: "knee" and "Knee" typed on two days
/// would be two injuries, and reading load against an injury later needs the same place named
/// the same way every time — the `Usernames` case-sensitivity bug again.
///
/// **Not `MuscleGroups`.** Knees, ankles and backs are joints and regions, not muscle groups,
/// and the catalogue's muscle ids are for training balance, not for saying what hurts.
///
/// **The raw value is stored.** Add cases; never rename one. An injury whose region this
/// version does not know is skipped on read, as an unknown schedule frequency is.
public enum InjuryRegion: String, CaseIterable, Codable, Hashable, Sendable {
    case hamstring
    case quad
    case calf
    case achilles
    case shin
    case knee
    case ankle
    case foot
    case hip
    case groin
    case glute
    case lowerBack
    case upperBack
    case neck
    case chest
    case abdominal
    case shoulder
    case elbow
    case wrist
    case hand
    case other

    /// Whether the region comes in a left and a right. A back, a neck or a chest does not.
    public var hasSide: Bool {
        switch self {
        case .lowerBack, .upperBack, .neck, .chest, .abdominal, .other:
            return false
        default:
            return true
        }
    }

    /// Lower case, so it reads inside a sentence: "Left hamstring", "Lower back".
    var name: String {
        switch self {
        case .hamstring: return "hamstring"
        case .quad: return "quad"
        case .calf: return "calf"
        case .achilles: return "achilles"
        case .shin: return "shin"
        case .knee: return "knee"
        case .ankle: return "ankle"
        case .foot: return "foot"
        case .hip: return "hip"
        case .groin: return "groin"
        case .glute: return "glute"
        case .lowerBack: return "lower back"
        case .upperBack: return "upper back"
        case .neck: return "neck"
        case .chest: return "chest"
        case .abdominal: return "abdominal"
        case .shoulder: return "shoulder"
        case .elbow: return "elbow"
        case .wrist: return "wrist"
        case .hand: return "hand"
        case .other: return "other"
        }
    }

    /// Plural for "Both …".
    var pluralName: String {
        switch self {
        case .foot: return "feet"
        case .calf: return "calves"
        case .achilles: return "achilles"
        default: return name + "s"
        }
    }
}
