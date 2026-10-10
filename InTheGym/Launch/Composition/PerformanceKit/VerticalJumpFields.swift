//
//  VerticalJumpFields.swift
//  InTheGym
//
//  Created by Findlay Wood on 10/10/2026.
//  Copyright © 2026 FindlayWood. All rights reserved.
//
import FirebaseFirestore
import PerformanceKit

/// The fields of a jump document, `time` and `height` (centimetres), the two
/// the legacy `VerticalJumpModel` encoded. **Both writers and both loaders use
/// this**, so the best and the history cannot drift apart, and documents
/// written before the move read the same way.
enum VerticalJumpFields {

    static func fields(of jump: VerticalJump) -> [String: Any] {
        ["time": jump.time, "height": jump.height]
    }

    static func jump(from document: DocumentSnapshot) -> VerticalJump? {
        guard let time = (document.get("time") as? Timestamp)?.dateValue(),
              let height = (document.get("height") as? NSNumber)?.doubleValue else {
            return nil
        }
        return VerticalJump(time: time, height: height)
    }
}
