//
//  Token.swift
//  Merlin
//
//  Created by Rod Schmidt on 8/4/18.
//  Copyright © 2018 infiniteNIL. All rights reserved.
//

import Foundation

public struct Token {
    let type: TokenType
    var literal: String
}

extension Token {
    init(_ type: TokenType, _ literal: String) {
        self.type = type
        self.literal = literal
    }

    init(_ type: TokenType, _ ch: Character) {
        self.type = type
        self.literal = String(ch)
    }
}

public enum TokenType: String {
    case illegal
    case eof

    case ident
    case int
    case string

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
    case function
    case `let`
    case `true`
    case `false`
    case `if`
    case `else`
    case `return`
    case macro
}

let keywords: [String: TokenType] = [
    "fn":       .function,
    "let":      .let,
    "true":     .true,
    "false":    .false,
    "if":       .if,
    "else":     .else,
    "return":   .return,
    "macro":    .macro,
]

func lookupIdentifier(_ ident: String) -> TokenType {
    return keywords[ident] ?? .ident
}
