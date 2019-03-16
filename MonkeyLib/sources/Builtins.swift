//
//  Builtins.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/15/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

var builtins: [String: Builtin] = [
    "len": Builtin(fn: len)
]

private func len(_ args: [MonkeyObject]) -> MonkeyObject? {
    if args.count != 1 {
        return newError(message: "wrong number of arguments. got=\(args.count), want=1")
    }

    let arg = args[0]

    switch arg {
    case is MonkeyString:
        return MonkeyInteger(value: (arg as! MonkeyString).value.count)

    default:
        return newError(message: "argument to 'len' not supported. got \(arg.type().rawValue)")
    }
}
