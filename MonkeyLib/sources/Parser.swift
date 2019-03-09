//
//  Parser.swift
//  MerlinLib
//
//  Created by Rod Schmidt on 8/5/18.
//

import Foundation

typealias PrefixParseFn = () -> Expression?
typealias InfixParseFn = (Expression) -> Expression?

enum Precedence: Int, Comparable {
    case lowest = 1
    case equals         // ==
    case lessGreater    // > or <
    case sum            // +
    case product        // *
    case prefix         // -x or !x
    case call           // myFunction(x)

    static func < (lhs: Precedence, rhs: Precedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

private let precedences: [TokenType: Precedence] = [
    .equal:     .equals,
    .notEqual:  .equals,
    .lt:        .lessGreater,
    .gt:        .lessGreater,
    .plus:      .sum,
    .minus:     .sum,
    .slash:     .product,
    .asterisk:  .product,
    .lparen:    .call,
]

public class Parser {
    private let lexer: Lexer
    private var currentToken = Token(type: .eof, literal: "")
    private var peekToken = Token(type: .eof, literal: "")
    private var prefixParseFns: [TokenType: PrefixParseFn] = [:]
    private var infixParseFns: [TokenType: InfixParseFn] = [:]
    public private(set) var errors: [String] = []

    public init(lexer: Lexer) {
        self.lexer = lexer

        registerPrefix(tokenType: .ident, fn: parseIdentifier)
        registerPrefix(tokenType: .int, fn: parseIntegerLiteral)
        registerPrefix(tokenType: .true, fn: parseBoolean)
        registerPrefix(tokenType: .false, fn: parseBoolean)
        registerPrefix(tokenType: .bang, fn: parsePrefixExpression)
        registerPrefix(tokenType: .minus, fn: parsePrefixExpression)
        registerPrefix(tokenType: .lparen, fn: parseGroupedExpression)
        registerPrefix(tokenType: .if, fn: parseIfExpression)
        registerPrefix(tokenType: .function, fn: parseFunctionLiteral)

        registerInfix(tokenType: .plus, fn: parseInfixExpression)
        registerInfix(tokenType: .minus, fn: parseInfixExpression)
        registerInfix(tokenType: .slash, fn: parseInfixExpression)
        registerInfix(tokenType: .asterisk, fn: parseInfixExpression)
        registerInfix(tokenType: .equal, fn: parseInfixExpression)
        registerInfix(tokenType: .notEqual, fn: parseInfixExpression)
        registerInfix(tokenType: .lt, fn: parseInfixExpression)
        registerInfix(tokenType: .gt, fn: parseInfixExpression)
        registerInfix(tokenType: .lparen, fn: parseCallExpression)

        // Read 2 tokens, so currentToken and peekToken are both set
        nextToken()
        nextToken()
    }

    func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFn) {
        prefixParseFns[tokenType] = fn
    }

    func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFn) {
        infixParseFns[tokenType] = fn
    }

    func nextToken() {
        currentToken = peekToken
        peekToken = lexer.nextToken()
    }

    public func parseProgram() -> Program? {
        var program = Program()

        while currentToken.type != .eof {
            if let stmt = parseStatement() {
                program.statements.append(stmt)
            }
            nextToken()
        }

        return program
    }

    private func parseStatement() -> Statement? {
        switch currentToken.type {
        case .let:      return parseLetStatement()
        case .return:   return parseReturnStatement()
        default:        return parseExpressionStatement()
        }
    }

    private func parseLetStatement() -> LetStatement? {
        let letToken = currentToken

        guard expectPeek(.ident) else { return nil }
        let name = Identifier(token: currentToken, value: currentToken.literal)
        guard expectPeek(.assign) else { return nil }

        nextToken()
        let value = parseExpression(precedence: .lowest)
        if peekToken.type == .semicolon {
            nextToken()
        }

        return LetStatement(token: letToken, name: name, value: value)
    }

    private func parseReturnStatement() -> ReturnStatement? {
        let token = currentToken
        nextToken()

        let returnValue = parseExpression(precedence: .lowest)
        if peekToken.type == .semicolon {
            nextToken()
        }

        return ReturnStatement(token: token, returnValue: returnValue)
    }

    private func parseExpressionStatement() -> ExpressionStatement {
        let token = currentToken
        let expression = parseExpression(precedence: .lowest)
        if peekToken.type == .semicolon {
            nextToken()
        }

        return ExpressionStatement(token: token, expression: expression)
    }

    private func parseExpression(precedence: Precedence) -> Expression? {
        guard let prefix = prefixParseFns[currentToken.type] else {
            noPrefixParseFnError(tokenType: currentToken.type)
            return nil
        }

        var leftExpr: Expression = prefix()!

        while peekToken.type != .semicolon && precedence < peekPrecedence() {
            guard let infix = infixParseFns[peekToken.type] else {
                return leftExpr
            }

            nextToken()
            leftExpr = infix(leftExpr)!
        }

        return leftExpr
    }

    func parseGroupedExpression() -> Expression? {
        nextToken()

        let expr = parseExpression(precedence: .lowest)
        if !expectPeek(.rparen) {
            return nil
        }

        return expr
    }

    func noPrefixParseFnError(tokenType: TokenType) {
        let msg = "no prefix parse function for \(tokenType) found"
        errors.append(msg)
    }

    private func parseIdentifier() -> Expression {
        return Identifier(token: currentToken, value: currentToken.literal)
    }

    private func parseIntegerLiteral() -> Expression? {
        let token = currentToken
        guard let value = Int(currentToken.literal) else {
            let msg = "could not parse \(currentToken.literal) as integer"
            errors.append(msg)
            return nil
        }

        return IntegerLiteral(token: token, value: value)
    }

    private func parseBoolean() -> Expression? {
        return BooleanLiteral(token: currentToken, value: currentToken.type == .true)
    }

    private func parsePrefixExpression() -> Expression? {
        let token = currentToken
        let op = currentToken.literal

        nextToken()
        let right = parseExpression(precedence: .prefix)

        return PrefixExpression(token: token, operator: op, right: right)
    }

    private func parseInfixExpression(left: Expression) -> Expression? {
        let token = currentToken
        let op = currentToken.literal

        let precedence = currentPrecedence()
        nextToken()
        let right = parseExpression(precedence: precedence)

        return InfixExpression(token: token, left: left, operator: op, right: right)
    }

    private func parseIfExpression() -> Expression? {
        let token = currentToken

        guard expectPeek(.lparen) else { return nil }
        nextToken()
        guard let condition = parseExpression(precedence: .lowest) else { return nil }

        guard expectPeek(.rparen) else { return nil }
        guard expectPeek(.lbrace) else { return nil }

        let consequence = parseBlockStatement()
        var alternative: BlockStatement?

        if peekToken.type == .else {
            nextToken()
            guard expectPeek(.lbrace) else { return nil }
            alternative = parseBlockStatement()
        }

        return IfExpression(token: token, condition: condition, consequence: consequence, alternative: alternative)
    }

    private func parseBlockStatement() -> BlockStatement {
        let token = currentToken
        var statements: [Statement] = []

        nextToken()
        while currentToken.type != .rbrace && currentToken.type != .eof {
            if let stmt = parseStatement() {
                statements.append(stmt)
            }
            nextToken()
        }

        return BlockStatement(token: token, statements: statements)
    }

    private func parseFunctionLiteral() -> Expression? {
        let token = currentToken

        guard expectPeek(.lparen) else { return nil }

        guard let parameters = parseFunctionParameters() else { return nil }

        guard expectPeek(.lbrace) else { return nil }

        let body = parseBlockStatement()

        return FunctionLiteral(token: token, parameters: parameters, body: body)
    }

    private func parseFunctionParameters() -> [Identifier]? {
        var identifiers: [Identifier] = []

        if peekToken.type == .rparen {
            nextToken()
            return identifiers
        }

        nextToken()
        let ident = Identifier(token: currentToken, value: currentToken.literal)
        identifiers.append(ident)

        while peekToken.type == .comma {
            nextToken()
            nextToken()
            let ident = Identifier(token: currentToken, value: currentToken.literal)
            identifiers.append(ident)
        }

        guard expectPeek(.rparen) else { return nil }

        return identifiers
    }

    private func parseCallExpression(_ function: Expression) -> Expression? {
        let token = currentToken
        guard let arguments = parseCallArguments() else { return nil }
        return CallExpression(token: token, function: function, arguments: arguments)
    }

    private func parseCallArguments() -> [Expression]? {
        var args: [Expression] = []

        if peekToken.type == .rparen {
            nextToken()
            return args
        }

        nextToken()
        guard let arg = parseExpression(precedence: .lowest) else { return nil }
        args.append(arg)

        while peekToken.type == .comma {
            nextToken()
            nextToken()
            guard let arg = parseExpression(precedence: .lowest) else { return nil }
            args.append(arg)
        }

        guard expectPeek(.rparen) else { return nil }
        return args
    }

    private func expectPeek(_ type: TokenType) -> Bool {
        if peekToken.type == type {
            nextToken()
            return true
        }
        else {
            peekError(expectedTokenType: type)
            return false
        }
    }

    private func peekError(expectedTokenType: TokenType) {
        let msg = "expected next token to be \(expectedTokenType.rawValue), got \(peekToken.type.rawValue) instead"
        errors.append(msg)
    }

    private func peekPrecedence() -> Precedence {
        return precedences[peekToken.type] ?? .lowest
    }

    private func currentPrecedence() -> Precedence {
        return precedences[currentToken.type] ?? .lowest
    }
}
