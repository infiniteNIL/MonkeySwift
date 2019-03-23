//
//  Token.swift
//  Merlin
//
//  Created by Rod Schmidt on 8/4/18.
//  Copyright © 2018 infiniteNIL. All rights reserved.
//

import Foundation

public struct Token {
    public let type: TokenType
    public var literal: String
}

public enum TokenType: String {
    case illegal = "ILLEGAL"
    case eof = "EOF"

    // Identifiers + literals
    case ident = "IDENT"    // add, foobar, x, y, ...
    case int = "INT"        // 123456
    case string = "STRING"

    // Operators
    case assign = "="
    case plus = "+"
    case minus = "-"
    case bang = "!"
    case asterisk = "*"
    case slash = "/"

    case lt = "<"
    case gt = ">"
    case equal = "=="
    case notEqual = "!="

    // Delimeters
    case comma = ","
    case semicolon = ";"

    case lparen = "("
    case rparen = ")"
    case lbrace = "{"
    case rbrace = "}"
    case lbracket = "["
    case rbracket = "]"
    case colon = ":"

    // Keywords
    case function = "FUNCTION"
    case `let` = "LET"
    case `true` = "true"
    case `false` = "false"
    case `if` = "if"
    case `else` = "else"
    case `return` = "return"
}

let keywords: [String: TokenType] = [
    "fn":       .function,
    "let":      .let,
    "true":     .true,
    "false":    .false,
    "if":       .if,
    "else":     .else,
    "return":   .return
]

func lookupIdentifier(_ ident: String) -> TokenType {
    return keywords[ident] ?? .ident
}
