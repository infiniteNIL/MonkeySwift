//
//  frame.swift
//  MonkeyLib
//
//  Created by Rod Schmidt on 4/9/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

class Frame {
    private let fn: CompiledFunction
    var ip: Int
    var basePointer: Int

    init(fn: CompiledFunction, basePointer: Int) {
        self.fn = fn
        ip = -1
        self.basePointer = basePointer
    }

    func instructions() -> Instructions {
        return fn.instructions
    }
}
