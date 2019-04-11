//
//  compiler.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

struct EmittedInstruction {
    var opcode: Opcode
    let position: Int
}

enum CompilerError: Error {
    case undefinedVariable(String)
}

struct CompilationScope {
    var instructions: Instructions
    var lastInstruction: EmittedInstruction?
    var previousInstruction: EmittedInstruction?
}

class Compiler {
    private var constants: [MonkeyObject]
    private(set) var symbolTable: SymbolTable
    private(set) var scopes: [CompilationScope]
    private(set) var scopeIndex: Int

    convenience init() {
        self.init(symbolTable: SymbolTable(), constants: [])
    }

    init(symbolTable: SymbolTable, constants: [MonkeyObject]) {
        self.constants = constants
        self.symbolTable = symbolTable

        for (i, builtin) in Builtins.enumerated() {
            symbolTable.defineBuiltin(i, builtin.name)
        }

        let mainScope = CompilationScope(instructions: [],
                                         lastInstruction: nil,
                                         previousInstruction: nil)
        scopes = [mainScope]
        scopeIndex = 0
    }

    func enterScope() {
        let scope = CompilationScope(instructions: [],
                                     lastInstruction: nil,
                                     previousInstruction: nil)
        scopes.append(scope)
        scopeIndex += 1

        symbolTable = SymbolTable(symbolTable)
    }

    @discardableResult
    func leaveScope() -> Instructions {
        let instructions = currentInstructions()

        scopes = scopes.dropLast()
        scopeIndex -= 1

        symbolTable = symbolTable.outer!
        return instructions
    }
    
    func compile(node: Node) throws {
        switch node {
        case is Program:
            let program = node as! Program
            for s in program.statements {
                try compile(node: s)
            }

        case is ExpressionStatement:
            let expressionStatment = node as! ExpressionStatement
            guard let expr = expressionStatment.expression else {
                fatalError("Expresssion statement has no expression")
            }
            try compile(node: expr)
            emit(op: .pop, operands: [])

        case is PrefixExpression:
            let prefix = node as! PrefixExpression
            guard let right = prefix.right else {
                fatalError("prefix expression has no right hand side")
            }
            try compile(node: right)

            switch prefix.operator {
            case "!": emit(op: .bang, operands: [])
            case "-": emit(op: .minus, operands: [])
            default:
                fatalError("Invalid prefix operator: \(prefix.operator)")
            }

        case is InfixExpression:
            let infix = node as! InfixExpression
            guard let right = infix.right else {
                fatalError("Infix expression has no right hand side")
            }
            if infix.operator == "<" {
                try compile(node: right)
                try compile(node: infix.left)
                emit(op: .greaterThan, operands: [])
                return
            }

            try compile(node: infix.left)
            try compile(node: right)

            switch infix.operator {
            case "+":   emit(op: .add, operands: [])
            case "-":   emit(op: .sub, operands: [])
            case "*":   emit(op: .mul, operands: [])
            case "/":   emit(op: .div, operands: [])
            case ">":   emit(op: .greaterThan, operands: [])
            case "==":  emit(op: .equal, operands: [])
            case "!=":  emit(op: .notEqual, operands: [])

            default:
                fatalError("Unknown operator \(infix.operator)")
            }

        case is IfExpression:
            let ifExpr = node as! IfExpression
            try compile(node: ifExpr.condition)
            let jumpNotTruthyPos = emit(op: .jumpNotTruthy, operands: [9999])
            try compile(node: ifExpr.consequence)
            if lastInstructionIs(op: .pop) {
                removeLastPop()
            }
            let jumpPos = emit(op: .jump, operands: [9999])
            let afterConsequencePos = currentInstructions().count
            changedOperand(opPos: Int(jumpNotTruthyPos), operand: afterConsequencePos)

            if let alt = ifExpr.alternative {
                try compile(node: alt)
                if lastInstructionIs(op: .pop) {
                    removeLastPop()
                }
            }
            else {
                emit(op: .null, operands: [])
            }

            let afterAlternativePos = currentInstructions().count
            changedOperand(opPos: Int(jumpPos), operand: afterAlternativePos)

        case is BlockStatement:
            let block = node as! BlockStatement
            for s in block.statements {
                try compile(node: s)
            }

        case is LetStatement:
            let letStmt = node as! LetStatement
            let symbol = symbolTable.define(name: letStmt.name.value)
            try compile(node: letStmt.value!)
            if symbol.scope == .global {
                emit(op: .setGlobal, operands: [UInt16(symbol.index)])
            }
            else {
                emit(op: .setLocal, operands: [UInt16(symbol.index)])
            }

        case is Identifier:
            let ident = node as! Identifier
            guard let symbol = symbolTable.resolve(name: ident.value) else {
                throw CompilerError.undefinedVariable(ident.value)
            }
            loadSymbol(symbol)

        case is IntegerLiteral:
            let intLiteral = node as! IntegerLiteral
            let integer = MonkeyInteger(value: intLiteral.value)
            _ = emit(op: .constant, operands: [addConstant(obj: integer)])

        case is BooleanLiteral:
            let boolLiteral = node as! BooleanLiteral
            emit(op: boolLiteral.value ? .pushTrue : .pushFalse, operands: [])

        case is StringLiteral:
            let s = node as! StringLiteral
            let str = MonkeyString(value: s.value)
            emit(op: .constant, operands: [addConstant(obj: str)])

        case is ArrayLiteral:
            let array = node as! ArrayLiteral
            for el in array.elements {
                try compile(node: el)
            }
            emit(op: .array, operands: [UInt16(array.elements.count)])

        case is HashLiteral:
            let hash = node as! HashLiteral
            let keys = hash.pairs
                .map { $0.0 }
                .sorted { $0.description < $1.description }

            for k in keys {
                try compile(node: k)
                let value = findValue(key: k, in: hash.pairs)
                try compile(node: value)
            }
            emit(op: .hash, operands: [UInt16(hash.pairs.count * 2)])

        case is IndexExpression:
            let indexExpr = node as! IndexExpression
            try compile(node: indexExpr.left)
            try compile(node: indexExpr.index)
            emit(op: .index, operands: [])

        case is FunctionLiteral:
            let fn = node as! FunctionLiteral
            enterScope()
            if let name = fn.name {
                symbolTable.defineFunctionName(name)
            }
            for p in fn.parameters {
                symbolTable.define(name: p.value)
            }
            try compile(node: fn.body)

            if lastInstructionIs(op: .pop) {
                replaceLastPopWithReturn()
            }

            if !lastInstructionIs(op: .returnValue) {
                emit(op: .return, operands: [])
            }

            let freeSymbols = symbolTable.freeSymbols
            let numLocals = symbolTable.numDefinitions
            let instructions = leaveScope()

            for s in freeSymbols {
                loadSymbol(s)
            }

            let compiledFn = CompiledFunction(instructions: instructions,
                                              numLocals: numLocals,
                                              numParameters: fn.parameters.count)
            let fnIndex = addConstant(obj: compiledFn)
            emit(op: .closure, operands: [fnIndex, UInt16(freeSymbols.count)])

        case is ReturnStatement:
            let ret = node as! ReturnStatement
            try compile(node: ret.returnValue!)
            emit(op: .returnValue, operands: [])

        case is CallExpression:
            let call = node as! CallExpression
            try compile(node: call.function)
            for a in call.arguments {
                try compile(node: a)
            }
            emit(op: .call, operands: [UInt16(call.arguments.count)])

        default:
            ()
        }
    }

    private func replaceLastPopWithReturn() {
        guard let lastInstruction = scopes[scopeIndex].lastInstruction else {
            fatalError("No last instruction")
        }
        let lastPos = lastInstruction.position
        replaceInstruction(pos: lastPos, newInstruction: make(op: .returnValue, operands: []))
        scopes[scopeIndex].lastInstruction?.opcode = .returnValue
    }

    private func findValue(key: Expression, in pairs: [(Expression, Expression)]) -> Expression {
        guard let pair = pairs.first(where: { $0.0.description == key.description }) else {
            fatalError("Unable to find pair in hash")
        }
        return pair.1
    }

    private func changedOperand(opPos: Int, operand: Int) {
        guard let op = Opcode(rawValue: currentInstructions()[opPos]) else {
            fatalError("Invalid opcode")
        }
        let newInstruction = make(op: op, operands: [UInt16(operand)])
        replaceInstruction(pos: opPos, newInstruction: newInstruction)
    }

    private func replaceInstruction(pos: Int, newInstruction: [UInt8]) {
        var ins = currentInstructions()

        for i in 0..<newInstruction.count {
            ins[pos + i] = newInstruction[i]
        }

        scopes[scopeIndex].instructions = ins
    }

    private func lastInstructionIs(op: Opcode) -> Bool {
        guard currentInstructions().count > 0 else { return false }
        return scopes[scopeIndex].lastInstruction?.opcode == op
    }

    private func removeLastPop() {
        guard let last = scopes[scopeIndex].lastInstruction else { fatalError("No last instruction") }
        let previous = scopes[scopeIndex].previousInstruction

        let old = currentInstructions()
        let new = Array(old[..<last.position])

        scopes[scopeIndex].instructions = new
        scopes[scopeIndex].lastInstruction = previous
    }

    func bytecode() -> Bytecode {
        return Bytecode(instructions: currentInstructions(), constants: constants)
    }

    private func addConstant(obj: MonkeyObject) -> UInt16 {
        constants.append(obj)
        return UInt16(constants.count - 1)
    }

    @discardableResult
    func emit(op: Opcode, operands: [UInt16]) -> UInt16 {
        let ins = make(op: op, operands: operands)
        let pos = addInstruction(ins)
        setLastInstruction(op: op, pos: Int(pos))
        return pos
    }

    private func setLastInstruction(op: Opcode, pos: Int) {
        let previous = scopes[scopeIndex].lastInstruction
        let last = EmittedInstruction(opcode: op, position: pos)
        scopes[scopeIndex].previousInstruction = previous
        scopes[scopeIndex].lastInstruction = last
    }

    private func addInstruction(_ ins: [UInt8]) -> UInt16 {
        let posNewInstruction = currentInstructions().count

        var updatedInstructions = currentInstructions()
        updatedInstructions += ins

        scopes[scopeIndex].instructions = updatedInstructions
        return UInt16(posNewInstruction)
    }

    private func currentInstructions() -> Instructions {
        return scopes[scopeIndex].instructions
    }

    private func loadSymbol(_ s: Symbol) {
        let op: Opcode
        switch s.scope {
        case .global:   op = .getGlobal
        case .local:    op = .getLocal
        case .builtin:  op = .getBuiltin
        case .free:     op = .getFree

        case .function:
            emit(op: .currentClosure, operands: [])
            return
        }
        
        emit(op: op, operands: [UInt16(s.index)])
    }
}

struct Bytecode {
    let instructions: Instructions
    let constants: [MonkeyObject]
}
