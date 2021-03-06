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

private var builtins: [String: Builtin] = [
    "first": getBuiltinByName("first")!,
    "last":  getBuiltinByName("last")!,
    "len":   getBuiltinByName("len")!,
    "push":  getBuiltinByName("push")!,
    "puts":  getBuiltinByName("puts")!,
    "rest":  getBuiltinByName("rest")!,
]

public func eval(_ node: Node, _ env: Environment) -> MonkeyObject? {
    switch node {
    case is Program:
        return evalProgram((node as! Program), env)

    case is BlockStatement:
        guard let node = node as? BlockStatement else { return nil }
        return evalBlockStatement(node, env)

    case is ReturnStatement:
        guard let node = node as? ReturnStatement else { return nil }
        guard let returnValue = node.returnValue else { return nil }
        guard let value = eval(returnValue, env) else { return nil }
        if isError(value) {
            return value
        }
        return ReturnValue(value: value)

    case is LetStatement:
        guard let node = node as? LetStatement else { return nil }
        guard let value = node.value else { return nil }
        let val = eval(value, env)
        if isError(val) { return val }
        if val != nil {
            env.set(name: node.name.value, value: val!)
        }
        return val

    case is Statement:
        guard let expression = (node as? ExpressionStatement)?.expression else { return nil }
        return eval(expression, env)

    case is PrefixExpression:
        guard let node = node as? PrefixExpression, node.right != nil else { return nil }
        guard let right = eval(node.right!, env) else { return nil }
        if isError(right) {
            return right
        }
        return evalPrefixExpression(node.operator, right)

    case is InfixExpression:
        guard let node = node as? InfixExpression, node.right != nil else { return nil }
        guard let left = eval(node.left, env) else { return nil }
        guard let right = eval(node.right!, env) else { return nil }
        if isError(right) {
            return right
        }
        return evalInfixExpression(node.operator, left, right)

    case is IfExpression:
        guard let node = node as? IfExpression else { return nil }
        return evalIfExpression(node, env)

    case is IntegerLiteral:
        let n = node as! IntegerLiteral
        return MonkeyInteger(value: n.value)

    case is StringLiteral:
        let n = node as! StringLiteral
        return MonkeyString(value: n.value)

    case is BooleanLiteral:
        let n = node as! BooleanLiteral
        return nativeBoolToBooleanObject(n.value)

    case is Identifier:
        let n = node as! Identifier
        return evalIdentifier(n, env)

    case is FunctionLiteral:
        guard let node = node as? FunctionLiteral else { return nil }
        let params = node.parameters
        let body = node.body
        return Function(parameters: params, body: body, env: env)

    case is CallExpression:
        guard let node = node as? CallExpression else { return nil }
        if node.function.tokenLiteral == "quote" {
            return quote(node.arguments[0], env)
        }
        
        let function = eval(node.function, env)
        if isError(function) {
            return function
        }
        let args = evalExpressions(node.arguments, env)
        if args.count == 1 && isError(args[0]) {
            return args[0]
        }
        return applyFunction(function, args)

    case is ArrayLiteral:
        let node = node as! ArrayLiteral
        let elements = evalExpressions(node.elements, env)
        if elements.count == 1 && isError(elements[0]) {
            return elements[0]
        }
        return MonkeyArray(elements: elements)

    case is IndexExpression:
        let node = node as! IndexExpression
        let left = eval(node.left, env)
        if isError(left) {
            return left
        }
        let index = eval(node.index, env)
        if isError(index) {
            return index
        }
        return evalIndexExpression(left, index)

    case is HashLiteral:
        let node = node as! HashLiteral
        return evalHashLiteral(node, env)

    default:
        return nil
    }
}

private func evalProgram(_ program: Program, _ env: Environment) -> MonkeyObject? {
    var result: MonkeyObject?

    for statement in program.statements {
        result = eval(statement, env)

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

private func evalBlockStatement(_ block: BlockStatement, _ env: Environment) -> MonkeyObject? {
    var result: MonkeyObject?

    for statement in block.statements {
        result = eval(statement, env)

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

private func evalIdentifier(_ node: Identifier, _ env: Environment) -> MonkeyObject {
    if let val = env.get(name: node.value) {
        return val
    }

    if let builtin = builtins[node.value] {
        return builtin
    }

    return newError(message: "identifier not found: \(node.value)")
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
    else if left.type() == .stringObj && right.type() == .stringObj {
        return evalStringInfixExpression(op, left, right)
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

private func evalStringInfixExpression(_ op: String, _ left: MonkeyObject, _ right: MonkeyObject) -> MonkeyObject {
    guard op == "+" else {
        return newError(message: "unknown operator: \(left.type().rawValue) \(op) \(right.type().rawValue)")
    }
    guard let leftVal = (left as? MonkeyString)?.value else { return Null }
    guard let rightVal = (right as? MonkeyString)?.value else { return Null }

    return MonkeyString(value: leftVal + rightVal)
}

private func evalIfExpression(_ ie: IfExpression, _ env: Environment) -> MonkeyObject? {
    guard let condition = eval(ie.condition, env) else { return nil }
    if isError(condition) {
        return condition
    }

    if isTruthy(condition) {
        return eval(ie.consequence, env)
    }
    else if let alt = ie.alternative {
        return eval(alt, env)
    }
    else {
        return Null
    }
}

private func evalExpressions(_ exprs: [Expression], _ env: Environment) -> [MonkeyObject] {
    var result: [MonkeyObject] = []

    for e in exprs {
        guard let evaluated = eval(e, env) else { return [] }
        if isError(evaluated) {
            return [evaluated]
        }
        result.append(evaluated)
    }

    return result
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

func newError(message: String) -> ErrorValue {
    return ErrorValue(message: message)
}

private func isError(_ obj: MonkeyObject?) -> Bool {
    return obj?.type() == .errorObj
}

private func applyFunction(_ fn: MonkeyObject?, _ args: [MonkeyObject]) -> MonkeyObject? {
    switch fn {
    case is Function:
        let fn = fn as! Function
        let extendedEnv = extendFunctionEnv(fn, args)
        let evaluated = eval(fn.body, extendedEnv)
        return unwrapReturnValue(evaluated)

    case is Builtin:
        if let result = (fn as! Builtin).fn(args) {
            return result
        }
        else {
            return Null
        }

    default:
        return newError(message: "not a function: \(String(describing: fn?.type()))")
    }
}

private func extendFunctionEnv(_ fn: Function, _ args: [MonkeyObject]) -> Environment {
    let env = Environment(outer: fn.env)

    for (paramIdx, param) in fn.parameters.enumerated() {
        env.set(name: param.value, value: args[paramIdx])
    }

    return env
}

private func unwrapReturnValue(_ obj: MonkeyObject?) -> MonkeyObject? {
    if let returnValue = obj as? ReturnValue {
        return returnValue.value
    }
    return obj
}

private func evalIndexExpression(_ left: MonkeyObject?, _ index: MonkeyObject?) -> MonkeyObject? {
    guard let left = left, let index = index else { return nil }

    switch (left.type(), index.type()) {
    case (.arrayObj, .integerObj):
        return evalArrayIndexExpression(left, index)

    case (.hashObj, _):
        return evalHashIndexExpression(left, index)

    default:
        return newError(message: "index operator not supported: \(left.type())")
    }
}

private func evalArrayIndexExpression(_ array: MonkeyObject, _ index: MonkeyObject) -> MonkeyObject? {
    guard let arrayObject = array as? MonkeyArray else { return nil }
    guard let idx = (index as? MonkeyInteger)?.value else { return nil }

    let max = arrayObject.elements.count - 1
    guard idx >= 0 && idx <= max else { return MonkeyNull() }

    return arrayObject.elements[idx]
}

private func evalHashLiteral(_ node: HashLiteral, _ env: Environment) -> MonkeyObject? {
    var pairs: [HashKey: HashPair] = [:]

    for (keyNode, valueNode) in node.pairs {
        guard let key = eval(keyNode, env) else { return nil }
        if isError(key) {
            return key
        }

        guard let hashKey = key as? MonkeyHashable else {
            return newError(message: "unusable as hash key: \(String(describing: key.type()))")
        }

        guard let value = eval(valueNode, env) else { return nil }
        if isError(value) {
            return value
        }

        let hashed = hashKey.hashKey()
        pairs[hashed] = HashPair(key: key, value: value)
    }

    return MonkeyHash(pairs: pairs)
}

private func evalHashIndexExpression(_ hash: MonkeyObject, _ index: MonkeyObject) -> MonkeyObject? {
    guard let hashObject = hash as? MonkeyHash else { return nil }
    guard let key = index as? MonkeyHashable else {
        return newError(message: "unusable as hash key: \(index.type().rawValue)")
    }

    guard let pair = hashObject.pairs[key.hashKey()] else {
        return MonkeyNull()
    }

    return pair.value
}
