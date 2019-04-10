//
//  Builtins.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/15/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

struct BuiltinInfo {
    let name: String
    let builtin: Builtin
}

var Builtins: [BuiltinInfo] = [
    BuiltinInfo(name: "len", builtin: Builtin(fn: len)),
    BuiltinInfo(name: "puts", builtin: Builtin(fn: puts)),
    BuiltinInfo(name: "first", builtin: Builtin(fn: first)),
    BuiltinInfo(name: "last", builtin: Builtin(fn: last)),
    BuiltinInfo(name: "rest", builtin: Builtin(fn: rest)),
    BuiltinInfo(name: "push", builtin: Builtin(fn: push)),
]

func getBuiltinByName(_ name: String) -> Builtin? {
    return Builtins.first(where: { $0.name == name })?.builtin
}

private func first(_ args: [MonkeyObject]) -> MonkeyObject? {
    guard args.count == 1 else {
        return newError(message: "wrong number of arguments. got=\(args.count), want=1")
    }

    guard args[0].type() == .arrayObj else {
        return newError(message: "argument to 'first' must be ARRAY, got \(args[0].type().rawValue)")
    }

    let arr = args[0] as! MonkeyArray
    if arr.elements.count > 0 {
        return arr.elements[0]
    }

    return nil
}

private func last(_ args: [MonkeyObject]) -> MonkeyObject? {
    guard args.count == 1 else {
        return newError(message: "wrong number of arguments. got=\(args.count), want=1")
    }

    guard args[0].type() == .arrayObj else {
        return newError(message: "argument to 'last' must be ARRAY, got \(args[0].type().rawValue)")
    }

    let arr = args[0] as! MonkeyArray
    if arr.elements.count > 0 {
        return arr.elements[arr.elements.count - 1]
    }

    return nil
}

private func len(_ args: [MonkeyObject]) -> MonkeyObject? {
    if args.count != 1 {
        return newError(message: "wrong number of arguments. got=\(args.count), want=1")
    }

    let arg = args[0]

    switch arg {
    case is MonkeyString:
        return MonkeyInteger(value: (arg as! MonkeyString).value.count)

    case is MonkeyArray:
        return MonkeyInteger(value: (arg as! MonkeyArray).elements.count)

    default:
        return newError(message: "argument to 'len' not supported. got \(arg.type().rawValue)")
    }
}

private func push(_ args: [MonkeyObject]) -> MonkeyObject? {
    guard args.count == 2 else {
        return newError(message: "wrong number of arguments. got=\(args.count), want=2")
    }

    guard args[0].type() == .arrayObj else {
        return newError(message: "argument to 'push' must be ARRAY, got \(args[0].type().rawValue)")
    }

    let arr = args[0] as! MonkeyArray
    return MonkeyArray(elements: [args[1]] + arr.elements)
}

private func rest(_ args: [MonkeyObject]) -> MonkeyObject? {
    guard args.count == 1 else {
        return newError(message: "wrong number of arguments. got=\(args.count), want=1")
    }

    guard args[0].type() == .arrayObj else {
        return newError(message: "argument to 'rest' must be ARRAY, got \(args[0].type().rawValue)")
    }

    let arr = args[0] as! MonkeyArray
    if arr.elements.count > 0 {
        let newElements = Array(arr.elements[1...])
        return MonkeyArray(elements: newElements)
    }

    return nil
}

private func puts(_ args: [MonkeyObject]) -> MonkeyObject? {
    for arg in args {
        print(arg.inspect())
    }
    return nil
}
