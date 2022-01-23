//
//  CustomCache.swift
//  InTheGym
//
//  Created by Findlay Wood on 21/01/2022.
//  Copyright © 2022 FindlayWood. All rights reserved.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    
    func insert(_ value: Value, forKey key: Key) {
        let entry = Entry(value)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }
    func value(forKey key: Key) -> Value? {
        let entry = wrapped.object(forKey: WrappedKey(key))
        return entry?.value
    }
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

// MARK: - Wrapped Key
/// wrap public facing Key values in order to make them NSCache compatible
private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) {
            self.key = key
        }
        
//        override func hash(into hasher: inout Hasher) {
//            hasher.combine(key)
//        }
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {return false}
            return value.key == key
        }
    }
}

// MARK: - Entry
private extension Cache {
    final class Entry {
        let value: Value
        
        init(_ value: Value) {
            self.value = value
        }
    }
}

// MARK: - Subscript
extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key)}
        set {
            guard let value = newValue else {
                removeValue(forKey: key)
                return
            }
            insert(value, forKey: key)
        }
    }
}
