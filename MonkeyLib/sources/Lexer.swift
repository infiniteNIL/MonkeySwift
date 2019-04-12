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

    /// current position in input (points to current character)
    private var position: String.Index

    /// current reading position in input (after current character)
    private var readPosition: String.Index

    /// current character under examination
    private var ch: Character? = nil

    public init(input: String) {
        self.input = input
        position = input.startIndex
        readPosition = input.startIndex
        readChar()
    }

    private func readChar() {
        guard readPosition < input.endIndex else {
            ch = nil
            position = input.endIndex
            readPosition = input.endIndex
            return
        }

        ch = input[readPosition]
        position = readPosition
        readPosition = input.index(after: readPosition)
    }

    public func nextToken() -> Token {
        skipWhitespace()
        guard let ch = ch else { return Token(.eof, "") }

        let token: Token

        switch ch {
        case "=":
            if peekChar() == "=" {
                readChar()
                token = Token(.equal, "==")
            }
            else {
                token = Token(.assign, ch)
            }

        case "+": token = Token(.plus, ch)
        case "-": token = Token(.minus, ch)

        case "!":
            if peekChar() == "=" {
                readChar()
                token = Token(.notEqual, "!=")
            }
            else {
                token = Token(.bang, ch)
            }

        case "/": token = Token(.slash, ch)
        case "*": token = Token(.asterisk, ch)
        case ">": token = Token(.gt, ch)
        case "<": token = Token(.lt, ch)
        case ";": token = Token(.semicolon, ch)
        case ",": token = Token(.comma, ch)
        case "(": token = Token(.lparen, ch)
        case ")": token = Token(.rparen, ch)
        case "{": token = Token(.lbrace, ch)
        case "}": token = Token(.rbrace, ch)

        case "\"": token = Token(.string, readString())
        case "[": token = Token(.lbracket, ch)
        case "]": token = Token(.rbracket, ch)
        case ":": token = Token(.colon, ch)

        default:
            if isLetter(ch) {
                let identifier = readIdentifier()
                return Token(lookupIdentifier(identifier), identifier)
            }
            else if isDigit(ch) {
                return Token(.int, readNumber())
            }
            else {
                return Token(.illegal, ch)
            }
        }

        readChar()
        return token
    }

    private func skipWhitespace() {
        let whitespace: [Character] = [" ", "\t", "\n", "\r"]

        while let ch = ch, whitespace.contains(ch) {
            readChar()
        }
    }

    private func peekChar() -> Character? {
        guard readPosition < input.endIndex else { return nil }
        return input[readPosition]
    }

    private func readString() -> String {
        let position = input.index(after: self.position)
        repeat {
            readChar()
        } while ch != "\"" && ch != nil
        return String(input[position..<self.position])
    }

    private func isLetter(_ ch: Character) -> Bool {
        return ch.isLetter || ch == "_"
    }

    private func readIdentifier() -> String {
        let position = self.position
        while let ch = ch, isLetter(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }

    private func isDigit(_ ch: Character) -> Bool {
        return ch.isASCII && ch.isWholeNumber
    }

    private func readNumber() -> String {
        let position = self.position
        while let ch = ch, isDigit(ch) {
            readChar()
        }
        return String(input[position..<self.position])
    }

}
