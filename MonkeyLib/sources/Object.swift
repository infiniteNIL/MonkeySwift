//
//  Object.swift
//  MerlinLib
//
//  Created by Rod Schmidt on 9/30/18.
//

import Foundation

public enum MonkeyObjectType: String {
    case integerObj = "INTEGER"
    case booleanObj = "BOOLEAN"
    case nullObj = "NULL"
    case returnValueObj = "RETURN_VALUE"
    case errorObj = "ERROR"
    case functionObj = "FUNCTION"
    case stringObj = "STRING"
    case builtinObj = "BUILTIN"
    case arrayObj = "ARRAY"
    case hashObj = "HASH"
    case quoteObj = "QUOTE"
    case macroObj = "MACRO"
    case compiledFunctionObj = "COMPILED_FUNCTION_OBJ"
}

struct HashKey: Hashable {
    let type: MonkeyObjectType
    let value: Int
}

public protocol MonkeyObject {
    func type() -> MonkeyObjectType
    func inspect() -> String
}

struct MonkeyInteger: Equatable {
    let value: Int
}

extension MonkeyInteger: MonkeyObject {

    func type() -> MonkeyObjectType {
        return .integerObj
    }

    func inspect() -> String {
        return "\(value)"
    }

    func hashKey() -> HashKey {
        return HashKey(type: .integerObj, value: value)
    }

}

struct MonkeyString: Equatable {
    let value: String
}

extension MonkeyString: MonkeyObject {

    func type() -> MonkeyObjectType {
        return .stringObj
    }

    func inspect() -> String {
        return value
    }

    func hashKey() -> HashKey {
        return HashKey(type: .stringObj, value: value.hashValue)
    }

}

public struct MonkeyBoolean: Equatable {
    let value: Bool
}

extension MonkeyBoolean: MonkeyObject {

    public func type() -> MonkeyObjectType {
        return .booleanObj
    }

    public func inspect() -> String {
        return "\(value)"
    }

    func hashKey() -> HashKey {
        let value = self.value ? 1 : 0
        return HashKey(type: .booleanObj, value: value)
    }

}

public struct MonkeyNull {}

extension MonkeyNull: MonkeyObject {

    public func type() -> MonkeyObjectType {
        return .nullObj
    }

    public func inspect() -> String {
        return "null"
    }

}

struct ReturnValue {
    let value: MonkeyObject
}

extension ReturnValue: MonkeyObject {

    public func type() -> MonkeyObjectType {
        return .returnValueObj
    }

    public func inspect() -> String {
        return "\(value)"
    }

}

struct ErrorValue {
    let message: String
}

extension ErrorValue: MonkeyObject {

    public func type() -> MonkeyObjectType {
        return .errorObj
    }

    public func inspect() -> String {
        return "ERROR: " + message
    }

}

struct Function: MonkeyObject {
    let parameters: [Identifier]
    let body: BlockStatement
    let env: Environment

    public func type() -> MonkeyObjectType {
        return .functionObj
    }

    public func inspect() -> String {
        let params = parameters.map { $0.description }
        return """
            fn(\(params.joined(separator: ", "))) {
                \(body.description)
            }
        """
    }
}

struct Macro: MonkeyObject {
    let parameters: [Identifier]
    let body: BlockStatement
    let env: Environment

    public func type() -> MonkeyObjectType {
        return .macroObj
    }

    public func inspect() -> String {
        let params = parameters.map { $0.description }
        return """
            macro(\(params.joined(separator: ", "))) {
                \(body.description)
            }
        """
    }
}

typealias BuiltinFunction = ([MonkeyObject]) -> MonkeyObject?

struct Builtin: MonkeyObject {
    let fn: BuiltinFunction

    func type() -> MonkeyObjectType {
        return .builtinObj
    }

    func inspect() -> String {
        return "builtin function"
    }

}

struct MonkeyArray: MonkeyObject {
    let elements: [MonkeyObject]

    func type() -> MonkeyObjectType {
        return .arrayObj
    }

    func inspect() -> String {
        return "[" + elements.map({ $0.inspect() }).joined(separator: ", ") + "]"
    }
}

struct HashPair {
    let key: MonkeyObject
    let value: MonkeyObject
}

struct MonkeyHash: MonkeyObject {
    let pairs: [HashKey: HashPair]

    func type() -> MonkeyObjectType {
        return .hashObj
    }

    func inspect() -> String {
        let pairStrings = pairs.map { "\($0.key.hashValue): \($0.value.value.inspect())" }
        return "{" + pairStrings.joined(separator: ", ") + "}"
    }
}

protocol MonkeyHashable {
    func hashKey() -> HashKey
}

extension MonkeyString: MonkeyHashable {}
extension MonkeyInteger: MonkeyHashable {}
extension MonkeyBoolean: MonkeyHashable {}

struct MonkeyQuote: MonkeyObject {
    let node: Node

    func type() -> MonkeyObjectType {
        return .quoteObj
    }

    func inspect() -> String {
        return "QUOTE(" + node.description + ")"
    }
}

struct CompiledFunction: MonkeyObject {
    let instructions: Instructions
    let numLocals: Int

    func type() -> MonkeyObjectType {
        return .compiledFunctionObj
    }

    func inspect() -> String {
        var s = self
        return withUnsafePointer(to: &s) { "CompiledFunction[\($0)]" }
    }
}
