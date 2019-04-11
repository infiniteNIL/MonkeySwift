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
    case builtin = "BUILTIN"
    case free = "FREE"
    case function = "FUNCTION"
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
    private(set) var freeSymbols: [Symbol] = []

    convenience init() {
        self.init(nil)
    }

    init(_ outer: SymbolTable?) {
        self.outer = outer
    }

    @discardableResult
    func define(name: String) -> Symbol {
        let symbol = Symbol(name: name,
                            scope: outer == nil ? .global : .local,
                            index: numDefinitions)
        store[name] = symbol
        numDefinitions += 1
        return symbol
    }

    @discardableResult
    func defineBuiltin(_ index: Int, _ name: String) -> Symbol {
        let symbol = Symbol(name: name, scope: .builtin, index: index)
        store[name] = symbol
        return symbol
    }

    @discardableResult
    func defineFree(_ original: Symbol) -> Symbol {
        freeSymbols.append(original)
        let symbol = Symbol(name: original.name, scope: .free, index: freeSymbols.count - 1)
        store[original.name] = symbol
        return symbol
    }

    @discardableResult
    func defineFunctionName(_ name: String) -> Symbol {
        let symbol = Symbol(name: name, scope: .function, index: 0)
        store[name] = symbol
        return symbol
    }

    func resolve(name: String) -> Symbol? {
        if let obj = store[name] {
            return obj
        }

        guard let outer = outer else { return nil }
        guard let obj = outer.resolve(name: name) else { return nil }

        if obj.scope == .global || obj.scope == .builtin {
            return obj
        }

        let free = defineFree(obj)
        return free
    }

}
