//
//  Environment.swift
//  MonkeyLib
//
//  Created by Rod Schmidt on 3/9/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

public class Environment {
    private var store: [String: MonkeyObject] = [:]
    private let outer: Environment?

    init() {
        outer = nil
    }

    init(outer: Environment) {
        self.outer = outer
    }

    func get(name: String) -> MonkeyObject? {
        if let value = store[name] {
            return value
        }
        else if let outer = outer {
            return outer.get(name: name)
        }
        else {
            return nil
        }
    }

    func set(name: String, value: MonkeyObject) {
        store[name] = value
    }
}
