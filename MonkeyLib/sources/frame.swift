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

    init(fn: CompiledFunction) {
        self.fn = fn
        ip = -1
    }

    func instructions() -> Instructions {
        return fn.instructions
    }
}
