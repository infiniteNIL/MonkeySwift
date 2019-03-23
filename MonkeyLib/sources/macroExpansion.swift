//
//  macroExpansion.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/23/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

public func defineMacros(_ program: inout Program, _ env: Environment) {
    var definitions: [Int] = []

    for (i, statement) in program.statements.enumerated() {
        if isMacroDefinition(statement) {
            addMacro(statement, env)
            definitions.append(i)
        }
    }

    for definitionNdx in definitions.reversed() {
        program.statements.remove(at: definitionNdx)
    }
}

public func expandMacros(_ program: Program, _ env: Environment) -> Node {
    return modify(program) { node in
        guard let callExpression = node as? CallExpression else { return node }
        guard let macro = isMacroCall(callExpression, env) else { return node }

        let args = quoteArgs(callExpression)
        let evalEnv = extendMacroEnv(macro, args)
        let evaluated = eval(macro.body, evalEnv)

        guard let quote = evaluated as? MonkeyQuote else {
            fatalError("We only support returning AST-nodes from macros")
        }

        return quote.node
    }
}

private func isMacroDefinition(_ node: Statement) -> Bool {
    guard let letStatement = node as? LetStatement else { return false }
    guard let _ = letStatement.value as? MacroLiteral else { return false }
    return true
}

private func addMacro(_ stmt: Statement, _ env: Environment) {
    let letStatement = stmt as! LetStatement
    let macroLiteral = letStatement.value as! MacroLiteral
    let macro = Macro(parameters: macroLiteral.parameters, body: macroLiteral.body, env: env)
    env.set(name: letStatement.name.value, value: macro)
}

private func isMacroCall(_ exp: CallExpression, _ env: Environment) -> Macro? {
    guard let identifier = exp.function as? Identifier else { return nil }
    guard let obj = env.get(name: identifier.value) else { return nil }
    return obj as? Macro
}

private func quoteArgs(_ exp: CallExpression) -> [MonkeyQuote] {
    return exp.arguments.map(MonkeyQuote.init(node:))
}

private func extendMacroEnv(_ macro: Macro, _ args: [MonkeyQuote]) -> Environment {
    let extended = Environment(outer: macro.env)
    for (paramIdx, param) in macro.parameters.enumerated() {
        extended.set(name: param.value, value: args[paramIdx])
    }
    return extended
}
