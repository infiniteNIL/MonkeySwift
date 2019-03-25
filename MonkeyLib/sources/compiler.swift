//
//  compiler.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

struct Compiler {
    private let instructions: Instructions
    private let constants: [MonkeyObject]

    init() {
        instructions = []
        constants = []
    }
    
    func compile(node: Node) -> Bool {
        return false
    }

    func bytecode() -> Bytecode {
        return Bytecode(instructions: [], constants: [])
    }
}

struct Bytecode {
    let instructions: Instructions
    let constants: [MonkeyObject]
}
