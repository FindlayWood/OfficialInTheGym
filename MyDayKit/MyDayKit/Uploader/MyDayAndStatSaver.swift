//
//  MyDayAndStatSaver.swift
//  MyDayKit
//
//  Created by Findlay Wood on 12/11/2025.
//

import Foundation

public protocol MyDayAndStatSaver {
    func save<T:Codable>(data: T, stats: ExerciseStatsSaveModel) async throws
}
