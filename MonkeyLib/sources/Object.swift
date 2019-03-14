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
