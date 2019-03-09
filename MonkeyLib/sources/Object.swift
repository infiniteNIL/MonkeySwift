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
