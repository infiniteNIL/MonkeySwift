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
    case local = "LOCAL"
}

struct Symbol: Equatable {
    let name: String
    let scope: SymbolScope
    let index: Int
}

class SymbolTable {
    let outer: SymbolTable?
    private var store: [String: Symbol] = [:]
    private(set) var numDefinitions: Int = 0

    @discardableResult
    func define(name: String) -> Symbol {
        let symbol = Symbol(name: name,
                            scope: outer == nil ? .global : .local,
                            index: numDefinitions)
        store[name] = symbol
        numDefinitions += 1
        return symbol
    }

    func resolve(name: String) -> Symbol? {
        return store[name] ?? outer?.resolve(name: name)
    }

    convenience init() {
        self.init(nil)
    }

    init(_ outer: SymbolTable?) {
        self.outer = outer
    }
}
