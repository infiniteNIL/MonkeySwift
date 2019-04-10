//
//  Repl.swift
//  Merlin
//
//  Created by Rod Schmidt on 8/5/18.
//

import Foundation

let prompt = ">> "

func startREPL() {
//    let env = Environment()
//    let macroEnv = Environment()

    var constants = [MonkeyObject]()
    var globals = [MonkeyObject?](repeating: nil, count: GlobalConstantsSize)
    var symbolTable = SymbolTable()
    for (i, builtin) in Builtins.enumerated() {
        symbolTable.defineBuiltin(i, builtin.name)
    }

    while true {
        print(prompt, terminator: "")

        guard let line = readLine(), !line.isEmpty else { break }
        let lexer = Lexer(input: line)
        let parser = Parser(lexer: lexer)

        let program = parser.parseProgram()
        if parser.errors.count > 0 {
            printParserErrors(parser.errors)
            continue
        }

        let compiler = Compiler(symbolTable: symbolTable, constants: constants)
        do {
            try compiler.compile(node: program!)
        }
        catch {
            print("Woops! Compilation failed:\n \(error)")
        }

        do {
            let code = compiler.bytecode()
            constants = code.constants
            symbolTable = compiler.symbolTable
            
            let machine = MonkeyVM(bytecode: code, globals: globals)
            try machine.run()
            let lastPoppped = machine.lastPopppedStackElem()
            print(lastPoppped.inspect())

            globals = machine.globals
        }
        catch {
            print("Woops! Executing bytecode failed:\n \(error)")
        }

        /*
        else if var program = program {
            defineMacros(&program, macroEnv)
            let expanded = expandMacros(program, macroEnv)
            if let evaluated = eval(expanded, env) {
                print(evaluated.inspect())
            }
        }
        */

        print()
    }
}

func printParserErrors(_ errors: [String]) {
    print("Errors:")
    errors.forEach { print("\t\($0)") }
}
