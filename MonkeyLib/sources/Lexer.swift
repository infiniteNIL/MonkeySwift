//
//  Lexer.swift
//  Merlin
//
//  Created by Rod Schmidt on 8/4/18.
//  Copyright © 2018 infiniteNIL. All rights reserved.
//

import Foundation

public class Lexer {
    private let input: String
    private var position: String.Index      // current position in input (points to current character)
    private var readPosition: String.Index  // current reading position in input (after current character)
    private var ch: Character? = nil        // current character under examination

    public init(input: String) {
        self.input = input
        position = input.startIndex
        readPosition = input.startIndex
        readChar()
    }

    public func nextToken() -> Token {
        let token: Token

        skipWhitespace()

        switch ch {
        case "=":
            if peekChar() == "=" {
                readChar()
                token = Token(type: .equal, literal: "==")
            }
            else {
                token = Token(type: .assign, literal: String(ch!))
            }

        case "+": token = Token(type: .plus, literal: String(ch!))
        case "-": token = Token(type: .minus, literal: String(ch!))

        case "!":
            if peekChar() == "=" {
                readChar()
                token = Token(type: .notEqual, literal: "!=")
            }
            else {
                token = Token(type: .bang, literal: String(ch!))
            }

        case "/": token = Token(type: .slash, literal: String(ch!))
        case "*": token = Token(type: .asterisk, literal: String(ch!))
        case ">": token = Token(type: .gt, literal: String(ch!))
        case "<": token = Token(type: .lt, literal: String(ch!))
        case ";": token = Token(type: .semicolon, literal: String(ch!))
        case ",": token = Token(type: .comma, literal: String(ch!))
        case "(": token = Token(type: .lparen, literal: String(ch!))
        case ")": token = Token(type: .rparen, literal: String(ch!))
        case "{": token = Token(type: .lbrace, literal: String(ch!))
        case "}": token = Token(type: .rbrace, literal: String(ch!))

        case nil: token = Token(type: .eof, literal: "")

        default:
            if isLetter(ch) {
                let identifier = readIdentifier()
                token = Token(type: lookupIdentifier(identifier), literal: identifier)
                return token
            }
            else if isDigit(ch) {
                token = Token(type: .int, literal: readNumber())
                return token
            }
            else {
                token = Token(type: .illegal, literal: String(ch!))
            }
        }

        readChar()
        return token
    }

    private func readChar() {
        if readPosition >= input.endIndex {
            ch = nil
            position = input.endIndex
            readPosition = input.endIndex
        }
        else {
            ch = input[readPosition]
            position = readPosition
            readPosition = input.index(after: readPosition)
        }
    }

    private func peekChar() -> Character? {
        if readPosition >= input.endIndex {
            return nil
        }
        else {
            return input[readPosition]
        }
    }

    private func readIdentifier() -> String {
        let position = self.position
        while isLetter(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }

    private func isLetter(_ ch: Character?) -> Bool {
        guard let ch = ch else { return false }
        return "a" <= ch && ch <= "z" || "A" <= ch && ch <= "Z" || ch == "_"
    }

    private func skipWhitespace() {
        while ch == " " || ch == "\t" || ch == "\n" || ch == "\r" {
            readChar()
        }
    }

    private func readNumber() -> String {
        let position = self.position
        while isDigit(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }

    private func isDigit(_ ch: Character?) -> Bool {
        guard let ch = ch else { return false }
        return "0" <= ch && ch <= "9"
    }

}
