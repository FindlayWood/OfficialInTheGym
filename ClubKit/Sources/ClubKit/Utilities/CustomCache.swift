//
//  CustomCache.swift
//
//
//  Created by Findlay Wood on 05/02/2024.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    
    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 2 * 60 * 60) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {return nil}
        
        guard dateProvider() < entry.expirationDate else {
            // remove expired data
            removeValue(forKey: key)
            return nil
        }
        return entry.value
    }
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    func removeAll(){
        wrapped.removeAllObjects()
    }
    func setLimit(to limit: Int) {
        wrapped.countLimit = limit
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
        let expirationDate: Date
        
        init(_ value: Value, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
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
