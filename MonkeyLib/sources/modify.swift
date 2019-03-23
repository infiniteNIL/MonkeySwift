//
//  modify.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/20/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

typealias ModifierFunc = (Node) -> Node

func modify(_ node: Node, _ modifier: ModifierFunc) -> Node {
    switch node {
    case is Program:
        var programNode = node as! Program
        for (i, statement) in programNode.statements.enumerated() {
            programNode.statements[i] = modify(statement, modifier) as! Statement
        }
        return modifier(programNode)

    case is ExpressionStatement:
        var expressionStatementNode = node as! ExpressionStatement
        expressionStatementNode.expression = (modify(expressionStatementNode.expression!, modifier) as! Expression)
        return modifier(expressionStatementNode)

    case is InfixExpression:
        var infix = node as! InfixExpression
        infix.left = modify(infix.left, modifier) as! Expression
        infix.right = (modify(infix.right!, modifier) as! Expression)
        return modifier(infix)

    case is PrefixExpression:
        var prefix = node as! PrefixExpression
        prefix.right = (modify(prefix.right!, modifier) as! Expression)
        return modifier(prefix)

    case is IndexExpression:
        var index = node as! IndexExpression
        index.left = modify(index.left, modifier) as! Expression
        index.index = modify(index.index, modifier) as! Expression
        return modifier(index)

    case is IfExpression:
        var node = node as! IfExpression
        node.condition = modify(node.condition, modifier) as! Expression
        node.consequence = modify(node.consequence, modifier) as! BlockStatement
        if let alt = node.alternative {
            node.alternative = (modify(alt, modifier) as! BlockStatement)
        }
        return modifier(node)

    case is BlockStatement:
        var node = node as! BlockStatement
        for i in 0..<node.statements.count {
            node.statements[i] = modify(node.statements[i], modifier) as! Statement
        }
        return modifier(node)

    case is ReturnStatement:
        var node = node as! ReturnStatement
        node.returnValue = (modify(node.returnValue!, modifier) as! Expression)
        return modifier(node)

    case is LetStatement:
        var node = node as! LetStatement
        node.value = (modify(node.value!, modifier) as! Expression)
        return modifier(node)

    case is FunctionLiteral:
        var node = node as! FunctionLiteral
        for i in 0..<node.parameters.count {
            node.parameters[i] = modify(node.parameters[i], modifier) as! Identifier
        }
        node.body = modify(node.body, modifier) as! BlockStatement
        return modifier(node)

    case is ArrayLiteral:
        var node = node as! ArrayLiteral
        for i in 0..<node.elements.count {
            node.elements[i] = modify(node.elements[i], modifier) as! Expression
        }
        return modifier(node)

    case is HashLiteral:
        var newPairs: [(Expression, Expression)] = []
        var node = node as! HashLiteral
        for (key, value) in node.pairs {
            let newKey = modify(key, modifier) as! Expression
            let newValue = modify(value, modifier) as! Expression
            newPairs.append((newKey, newValue))
        }
        node.pairs = newPairs
        return modifier(node)

    default:
        return modifier(node)
    }
}
