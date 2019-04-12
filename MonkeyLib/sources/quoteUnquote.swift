//
//  quoteUnquote.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/20/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

func quote(_ node: Node, _ env: Environment) -> MonkeyObject {
    let newNode = evalUnquoteCalls(node, env)
    return MonkeyQuote(node: newNode)
}

private func evalUnquoteCalls(_ quoted: Node, _ env: Environment) -> Node {
    return modify(quoted) { node in
        if !isUnquotedCall(node) {
            return node
        }

        guard let call = node as? CallExpression else {
            return node
        }

        if call.arguments.count != 1 {
            return node
        }

        guard let unquoted = eval(call.arguments[0], env) else {
            return node
        }

        guard let newNode = convertObjectToASTNode(unquoted) else {
            return node
        }

        return newNode
    }
}

private func isUnquotedCall(_ node: Node) -> Bool {
    guard let callExpression = node as? CallExpression else {
        return false
    }

    return callExpression.function.tokenLiteral() == "unquote"
}

private func convertObjectToASTNode(_ object: MonkeyObject) -> Node? {
    switch object {
    case is MonkeyInteger:
        let integer = object as! MonkeyInteger
        let t = Token(.int, "\(integer.value)")
        return IntegerLiteral(token: t, value: integer.value)

    case is MonkeyBoolean:
        let b = object as! MonkeyBoolean
        let t: Token
        if b.value {
            t = Token(.true, "true")
        }
        else {
            t = Token(.false, "false")
        }
        return BooleanLiteral(token: t, value: b.value)

    case is MonkeyQuote:
        let quote = object as! MonkeyQuote
        return quote.node

    default:
        return nil
    }
}
