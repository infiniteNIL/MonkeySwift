//
//  frame.swift
//  MonkeyLib
//
//  Created by Rod Schmidt on 4/9/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

class Frame {
    let cl: Closure
    var ip: Int
    var basePointer: Int

    init(cl: Closure, basePointer: Int) {
        self.cl = cl
        ip = -1
        self.basePointer = basePointer
    }

    func instructions() -> Instructions {
        return cl.fn.instructions
    }
}
