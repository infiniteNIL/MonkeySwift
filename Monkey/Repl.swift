//
//  Repl.swift
//  Merlin
//
//  Created by Rod Schmidt on 8/5/18.
//

import Foundation

let prompt = ">> "

func startREPL() {
    while true {
        print(prompt, terminator: "")

        guard let line = readLine(), !line.isEmpty else { break }
        let lexer = Lexer(input: line)
        let parser = Parser(lexer: lexer)

        let program = parser.parseProgram()
        if parser.errors.count > 0 {
            printParserErrors(parser.errors)
        }
        else if let program = program {
            if let evaluated = eval(program) {
                print(evaluated.inspect())
            }
        }

        print()
    }
}

func printParserErrors(_ errors: [String]) {
    print("Errors:")
    errors.forEach { print("\t\($0)") }
}
