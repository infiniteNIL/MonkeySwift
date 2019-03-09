//
//  Evaluator.swift
//  MerlinLib
//
//  Created by Rod Schmidt on 9/30/18.
//

import Foundation

public let True = MonkeyBoolean(value: true)
public let False = MonkeyBoolean(value: false)
public let Null = MonkeyNull()

public func eval(_ node: Node) -> MonkeyObject? {
    switch node {
    case is Program:
        return evalProgram((node as! Program))

    case is BlockStatement:
        guard let node = node as? BlockStatement else { return nil }
        return evalBlockStatement(node)

    case is ReturnStatement:
        guard let node = node as? ReturnStatement else { return nil }
        guard let returnValue = node.returnValue else { return nil }
        guard let value = eval(returnValue) else { return nil }
        if isError(value) {
            return value
        }
        return ReturnValue(value: value)

    case is Statement:
        guard let expression = (node as? ExpressionStatement)?.expression else { return nil }
        return eval(expression)

    case is PrefixExpression:
        guard let node = node as? PrefixExpression, node.right != nil else { return nil }
        guard let right = eval(node.right!) else { return nil }
        if isError(right) {
            return right
        }
        return evalPrefixExpression(node.operator, right)

    case is InfixExpression:
        guard let node = node as? InfixExpression, node.right != nil else { return nil }
        guard let left = eval(node.left) else { return nil }
        guard let right = eval(node.right!) else { return nil }
        if isError(right) {
            return right
        }
        return evalInfixExpression(node.operator, left, right)

    case is IfExpression:
        guard let node = node as? IfExpression else { return nil }
        return evalIfExpression(node)

    case is IntegerLiteral:
        let n = node as! IntegerLiteral
        return MonkeyInteger(value: n.value)

    case is BooleanLiteral:
        let n = node as! BooleanLiteral
        return nativeBoolToBooleanObject(n.value)

    default:
        return nil
    }
}

private func evalProgram(_ program: Program) -> MonkeyObject? {
    var result: MonkeyObject?

    for statement in program.statements {
        result = eval(statement)

        switch result {
        case is ReturnValue:
            return (result as! ReturnValue).value

        case is ErrorValue:
            return result

        default: break // nop
        }
    }

    return result
}

private func evalBlockStatement(_ block: BlockStatement) -> MonkeyObject? {
    var result: MonkeyObject?

    for statement in block.statements {
        result = eval(statement)

        if let result = result, result.type() == .returnValueObj  || result.type() == .errorObj {
            return result
        }
    }

    return result
}

private func evalPrefixExpression(_ op: String, _ right: MonkeyObject) -> MonkeyObject {
    switch op {
    case "!":
        return evalBangOperatorExpression(right)

    case "-":
        return evalMinusPrefixOperatorExpression(right)

    default:
        return newError(message: "unknown operator: \(op)\(right.type().rawValue)")
    }
}

private func evalBangOperatorExpression(_ right: MonkeyObject) -> MonkeyObject {
    if let right = right as? MonkeyBoolean {
        return right == True ? False : True
    }
    else if let _ = right as? MonkeyNull {
        return True
    }
    else {
        return False
    }
}

private func evalMinusPrefixOperatorExpression(_ right: MonkeyObject) -> MonkeyObject {
    if right.type() != .integerObj {
        return newError(message: "unknown operator: -\(right.type().rawValue)")
    }

    let value = (right as! MonkeyInteger).value
    return MonkeyInteger(value: -value)
}

private func nativeBoolToBooleanObject(_ input: Bool) -> MonkeyBoolean {
    return input ? True : False
}

private func evalInfixExpression(_ op: String, _ left: MonkeyObject, _ right: MonkeyObject) -> MonkeyObject {
    if left.type() == .integerObj && right.type() == .integerObj {
        return evalIntegerInfixExpression(op, left, right)
    }
    else if left.type() == .booleanObj && right.type() == .booleanObj {
        guard let left  = (left as? MonkeyBoolean) else { return Null }
        guard let right  = (right as? MonkeyBoolean) else { return Null }
        switch op {
        case "==":  return nativeBoolToBooleanObject(left.value == right.value)
        case "!=":  return nativeBoolToBooleanObject(left.value != right.value)
        default:    return newError(message: "unknown operator: \(left.type().rawValue) \(op) \(right.type().rawValue)")
        }
    }
    else if left.type() != right.type() {
        return newError(message: "type mismatch: \(left.type().rawValue) \(op) \(right.type().rawValue)")
    }
    else {
        return newError(message: "unknown operator: \(left.type().rawValue) \(op) \(right.type().rawValue)")
    }
}

private func evalIntegerInfixExpression(_ op: String, _ left: MonkeyObject, _ right: MonkeyObject) -> MonkeyObject {
    guard let leftVal = (left as? MonkeyInteger)?.value else { return Null }
    guard let rightVal = (right as? MonkeyInteger)?.value else { return Null }

    switch op {
    case "+":   return MonkeyInteger(value: leftVal + rightVal)
    case "-":   return MonkeyInteger(value: leftVal - rightVal)
    case "*":   return MonkeyInteger(value: leftVal * rightVal)
    case "/":   return MonkeyInteger(value: leftVal / rightVal)
    case ">":   return nativeBoolToBooleanObject(leftVal > rightVal)
    case "<":   return nativeBoolToBooleanObject(leftVal < rightVal)
    case "==":  return nativeBoolToBooleanObject(leftVal == rightVal)
    case "!=":  return nativeBoolToBooleanObject(leftVal != rightVal)
    default:    return newError(message: "unknown operator: \(left.type().rawValue) \(op) \(right.type().rawValue)")
    }
}

private func evalIfExpression(_ ie: IfExpression) -> MonkeyObject? {
    guard let condition = eval(ie.condition) else { return nil }
    if isError(condition) {
        return condition
    }

    if isTruthy(condition) {
        return eval(ie.consequence)
    }
    else if let alt = ie.alternative {
        return eval(alt)
    }
    else {
        return Null
    }
}

private func isTruthy(_ object: MonkeyObject) -> Bool {
    if let b = object as? MonkeyBoolean {
        return b.value == true
    }
    else if object is MonkeyNull {
        return false
    }
    else {
        return true
    }
}

private func newError(message: String) -> ErrorValue {
    return ErrorValue(message: message)
}

private func isError(_ obj: MonkeyObject?) -> Bool {
    return obj?.type() == .errorObj
}
