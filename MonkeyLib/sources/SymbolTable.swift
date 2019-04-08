//
//  SymbolTable.swift
//  Monkey
//
//  Created by Rod Schmidt on 4/7/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

enum SymbolScope: String, Equatable {
    case global = "GLOBAL"
}

struct Symbol: Equatable {
    let name: String
    let scope: SymbolScope
    let index: Int
}

class SymbolTable {
    private var store: [String: Symbol] = [:]
    private var numDefinitions: Int = 0

    @discardableResult
    func define(name: String) -> Symbol {
        let symbol = Symbol(name: name, scope: .global, index: numDefinitions)
        store[name] = symbol
        numDefinitions += 1
        return symbol
    }

    func resolve(name: String) -> Symbol? {
        return store[name]
    }
}
