//
//  AST.swift
//  MerlinLib
//
//  Created by Rod Schmidt on 8/5/18.
//

import Foundation

public protocol Node: CustomStringConvertible {
    func tokenLiteral() -> String
}

protocol Statement: Node {}

protocol Expression: Node {}

public struct Program: Node {
    var statements: [Statement] = []

    public func tokenLiteral() -> String {
        if statements.count > 0 {
            return statements[0].tokenLiteral()
        }
        else {
            return ""
        }
    }

    public var description: String {
        return statements
            .map { $0.description }
            .joined()
    }
}

struct LetStatement: Statement {
    let token: Token
    var name: Identifier
    var value: Expression?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let value = self.value?.description ?? ""
        return "\(token.literal) \(name) = \(value);"
    }
}

struct Identifier: Expression {
    let token: Token
    let value: String

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return value
    }
}

struct ReturnStatement: Statement {
    let token: Token
    var returnValue: Expression?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let value = returnValue?.description ?? ""
        return "\(token.literal) \(value);"
    }
}

struct ExpressionStatement: Statement, Expression {
    let token: Token
    var expression: Expression?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return expression?.description ?? ""
    }
}

struct IntegerLiteral: Expression {
    var token: Token
    var value: Int

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

extension IntegerLiteral {
    init(value: Int) {
        self.token = Token(type: .int, literal: "\(value)")
        self.value = value
    }
}

struct StringLiteral: Expression {
    let token: Token
    let value: String

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

struct BooleanLiteral: Expression {
    let token: Token
    let value: Bool

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return token.literal
    }
}

struct PrefixExpression: Expression {
    let token: Token
    let `operator`: String
    var right: Expression?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let right = self.right?.description ?? ""
        return "(\(self.operator)\(right))"
    }
}

struct InfixExpression: Expression {
    let token: Token
    var left: Expression
    let `operator`: String
    var right: Expression?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let right = self.right?.description ?? ""
        return "(\(left) \(self.operator) \(right))"
    }
}

struct IfExpression: Expression {
    let token: Token
    var condition: Expression
    var consequence: BlockStatement
    var alternative: BlockStatement?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        var result = "if \(condition) \(consequence)"
        if let alt = alternative {
            result += " else \(alt)"
        }
        return result
    }
}

struct BlockStatement: Statement {
    let token: Token
    var statements: [Statement]

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return statements
            .map { $0.description }
            .joined()
    }
}

struct FunctionLiteral: Expression {
    let token: Token
    var parameters: [Identifier]
    var body: BlockStatement
    var name: String?

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let params = parameters
            .map { $0.description }
            .joined()

        return "\(tokenLiteral())<\(name ?? "NoName")>(\(params)) \(body)"
    }
}

struct CallExpression: Expression {
    let token: Token    // The '(' token
    let function: Expression
    let arguments: [Expression]

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let args = arguments
            .map { String(describing: $0) }
            .joined(separator: ", ")

        return "\(function)(\(args))"
    }
}

struct ArrayLiteral: Expression {
    let token: Token
    var elements: [Expression]

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        let elementsString = elements
            .map { String(describing: $0) }
            .joined(separator: ", ")
        return "[" + elementsString + "]"
    }
}

struct IndexExpression: Expression {
    let token: Token    // The [
    var left: Expression
    var index: Expression

    func tokenLiteral() -> String {
        return token.literal
    }

    var description: String {
        return "(" + left.description + "[" + index.description + "])"
    }
}

struct HashLiteral: Expression {
    let token: Token
    var pairs: [(Expression, Expression)]

    var description: String {
        var pairStrings: [String] = []
        for (key, value) in pairs {
            pairStrings.append(key.description + ": " + value.description)
        }

        return "{" + pairStrings.joined(separator: ", ") + "}"
    }

    func tokenLiteral() -> String { return token.literal }
}

struct MacroLiteral: Expression {
    let token: Token
    let parameters: [Identifier]
    let body: BlockStatement

    var description: String {
        let paramStrings = parameters.map { $0.description }
        return "\(tokenLiteral()) (" + paramStrings.joined(separator: ", ") + ") + \(body.description)"
    }

    func tokenLiteral() -> String { return token.literal }
}
