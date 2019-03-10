//
//  Environment.swift
//  MonkeyLib
//
//  Created by Rod Schmidt on 3/9/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

public struct Environment {
    private var store: [String: MonkeyObject] = [:]

    func get(name: String) -> MonkeyObject? {
        return store[name]
    }

    mutating func set(name: String, value: MonkeyObject) {
        store[name] = value
    }
}
