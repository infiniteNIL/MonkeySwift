//
//  ModifyTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/20/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation
import XCTest
@testable import MonkeyLib

class ModifyTests: XCTestCase {

    override func setUp() {}

    override func tearDown() {}

    func testModify() {
        let one = { return IntegerLiteral(value: 1) }
        let oneToken = Token(.int, "1")
        let two = { return IntegerLiteral(value: 2) }
        let twoToken = Token(.int, "2")

        let turnOneIntoTwo = { (node: Node) -> Node in
            guard var integer = node as? IntegerLiteral else { return node }
            if integer.value != 1 {
                return node
            }
            integer.value = 2
            return integer
        }

        struct Test {
            let input: Node
            let expected: Node
        }

        let tests: [Test] = [
            Test(input: one(), expected: two()),
            Test(
                input: Program(statements: [
                    ExpressionStatement(token: oneToken, expression: one())
                ]),
                expected: Program(statements: [
                    ExpressionStatement(token: twoToken, expression: two())
                ])
            ),

            Test(input: InfixExpression(token: oneToken, left: one(), operator: "+", right: two()),
                 expected: InfixExpression(token: twoToken, left: two(), operator: "+", right: two())),

            Test(input: PrefixExpression(token: oneToken, operator: "-", right: one()),
                 expected: PrefixExpression(token: twoToken, operator: "-", right: two())),

            Test(input: IndexExpression(token: oneToken, left: one(), index: one()),
                 expected: IndexExpression(token: twoToken, left: two(), index: two())),

            Test(
                input: IfExpression(
                    token: Token(.if, "if"),
                    condition: one(),
                    consequence: BlockStatement(
                        token: oneToken,
                        statements: [ExpressionStatement(
                            token: oneToken, expression: one()
                        )]
                    ),
                    alternative: BlockStatement(
                        token: Token(.else, "else"),
                        statements: [ExpressionStatement(
                            token: oneToken, expression: one())
                        ]
                    )
                ),
                expected: IfExpression(
                    token: Token(.if, "if"),
                    condition: two(),
                    consequence: BlockStatement(
                        token: twoToken,
                        statements: [ExpressionStatement(
                            token: twoToken, expression: two()
                        )]
                    ),
                    alternative: BlockStatement(
                        token: Token(.else, "else"),
                        statements: [ExpressionStatement(
                            token: twoToken, expression: two())
                        ]
                    )
                )
            ),

            Test(input: ReturnStatement(token: oneToken, returnValue: one()),
                 expected: ReturnStatement(token: twoToken, returnValue: two())),

            Test(input: LetStatement(token: oneToken,
                                     name: Identifier(token: oneToken, value: "one"),
                                     value: one()),
                 expected:  LetStatement(token: twoToken,
                                         name: Identifier(token: twoToken, value: "two"),
                                         value: two())
            ),

            Test(input: FunctionLiteral(token: Token(.function, "fn"),
                                        parameters: [],
                                        body: BlockStatement(token: oneToken, statements: [
                                                ExpressionStatement(token: oneToken, expression: one())
                                            ]),
                                        name: nil),
                 expected: FunctionLiteral(token: Token(.function, "fn"),
                                           parameters: [],
                                           body: BlockStatement(token: twoToken, statements: [
                                                ExpressionStatement(token: twoToken, expression: two())
                                            ]),
                                        name: nil)
            ),

            Test(input: ArrayLiteral(token: Token(.lbracket, "["), elements: [one(), one()]),
                 expected: ArrayLiteral(token: Token(.lbracket, "["), elements: [two(), two()])),

            Test(input: HashLiteral(token: Token(.lbrace, "{"),
                                    pairs: [(one(), one())]),
                 expected: HashLiteral(token: Token(.lbrace, "{"),
                                       pairs: [(two(), two())])
            ),
        ]

        for t in tests {
            let modified = modify(t.input, turnOneIntoTwo)
            XCTAssertTrue(equalNodes(modified, t.expected), "not equal. got=\(modified), want=\(t.expected)")
        }
    }
}

private func equalNodes(_ lhs: Node, _ rhs: Node) -> Bool {
    switch lhs {
    case is IntegerLiteral:
        let lhs = lhs as! IntegerLiteral
        guard let rhs = rhs as? IntegerLiteral else { return false }
        return lhs.value == rhs.value

    case is Program:
        let lhs = lhs as! Program
        guard let rhs = rhs as? Program else { return false }
        guard lhs.statements.count == rhs.statements.count else { return false }
        for i in 0..<lhs.statements.count {
            let lhsStatement = lhs.statements[i]
            let rhsStatement = rhs.statements[i]
            guard equalNodes(lhsStatement, rhsStatement) else { return false }
        }
        return true

    case is ExpressionStatement:
        let lhs = lhs as! ExpressionStatement
        guard let rhs = rhs as? ExpressionStatement else { return false }
        guard let lhsExpression = lhs.expression else { return false }
        guard let rhsExpression = rhs.expression else { return false }
        return equalNodes(lhsExpression, rhsExpression)

    case is InfixExpression:
        let lhs = lhs as! InfixExpression
        guard let rhs = rhs as? InfixExpression else { return false }
        guard equalNodes(lhs.left, rhs.left) else { return false }
        guard let lhsRight = lhs.right else { return false }
        guard let rhsRight = rhs.right else { return false }
        return equalNodes(lhsRight, rhsRight)

    case is PrefixExpression:
        let lhs = lhs as! PrefixExpression
        guard let rhs = rhs as? PrefixExpression else { return false }
        guard let lhsExpression = lhs.right else { return false }
        guard let rhsExpression = rhs.right else { return false }
        return equalNodes(lhsExpression, rhsExpression)

    case is IndexExpression:
        let lhs = lhs as! IndexExpression
        guard let rhs = rhs as? IndexExpression else { return false }
        guard equalNodes(lhs.left, rhs.left) else { return false }
        return equalNodes(lhs.index, rhs.index)

    case is IfExpression:
        let lhs = lhs as! IfExpression
        guard let rhs = rhs as? IfExpression else { return false }
        guard equalNodes(lhs.condition, rhs.condition) else { return false }
        guard equalNodes(lhs.consequence, rhs.consequence) else { return false }
        if let lhsAlt = lhs.alternative {
            guard let rhsAlt = rhs.alternative else { return false }
            guard equalNodes(lhsAlt, rhsAlt) else { return false }
        }
        return true

    case is BlockStatement:
        let lhs = lhs as! BlockStatement
        guard let rhs = rhs as? BlockStatement else { return false }
        guard rhs.statements.count == lhs.statements.count else { return false }
        for i in 0..<lhs.statements.count {
            guard equalNodes(lhs.statements[i], rhs.statements[i]) else { return false }
        }
        return true

    case is ReturnStatement:
        let lhs = lhs as! ReturnStatement
        guard let rhs = rhs as? ReturnStatement else { return false }
        return equalNodes(lhs.returnValue!, rhs.returnValue!)

    case is LetStatement:
        let lhs = lhs as! LetStatement
        guard let rhs = rhs as? LetStatement else { return false }
        return equalNodes(lhs.value!, rhs.value!)

    case is FunctionLiteral:
        let lhs = lhs as! FunctionLiteral
        guard let rhs = rhs as? FunctionLiteral else { return false }
        guard lhs.parameters.count == rhs.parameters.count else { return false }
        for i in 0..<lhs.body.statements.count {
            guard equalNodes(lhs.body.statements[i], rhs.body.statements[i]) else { return false }
        }
        return true

    case is ArrayLiteral:
        let lhs = lhs as! ArrayLiteral
        guard let rhs = rhs as? ArrayLiteral else { return false }
        guard lhs.elements.count == rhs.elements.count else { return false }
        for i in 0..<lhs.elements.count {
            guard equalNodes(lhs.elements[i], rhs.elements[i]) else { return false }
        }
        return true

    case is HashLiteral:
        let lhs = lhs as! HashLiteral
        guard let rhs = rhs as? HashLiteral else { return false }
        guard lhs.pairs.count == rhs.pairs.count else { return false }
        for i in 0..<lhs.pairs.count {
            let (lhsKey, lhsValue) = lhs.pairs[i]
            let (rhsKey, rhsValue) = rhs.pairs[i]
            guard equalNodes(lhsKey, rhsKey) else { return false }
            guard equalNodes(lhsValue, rhsValue) else { return false }
        }
        return true

    default:
        return false
    }
}
