//
//  compiler.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

struct EmittedInstruction {
    let opcode: Opcode
    let position: Int
}

enum CompilerError: Error {
    case undefinedVariable(String)
}

class Compiler {
    private var instructions: Instructions
    private var constants: [MonkeyObject]
    private var lastInstruction: EmittedInstruction?
    private var previousInstruction: EmittedInstruction?
    private(set) var symbolTable: SymbolTable

    init() {
        instructions = []
        constants = []
        symbolTable = SymbolTable()
    }

    init(symbolTable: SymbolTable, constants: [MonkeyObject]) {
        instructions = []
        self.constants = constants
        self.symbolTable = symbolTable
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
            if lastInstructionIsPop() {
                removeLastPop()
            }
            let jumpPos = emit(op: .jump, operands: [9999])
            let afterConsequencePos = instructions.count
            changedOperand(opPos: Int(jumpNotTruthyPos), operand: afterConsequencePos)

            if let alt = ifExpr.alternative {
                try compile(node: alt)
                if lastInstructionIsPop() {
                    removeLastPop()
                }
            }
            else {
                emit(op: .null, operands: [])
            }

            let afterAlternativePos = instructions.count
            changedOperand(opPos: Int(jumpPos), operand: afterAlternativePos)

        case is BlockStatement:
            let block = node as! BlockStatement
            for s in block.statements {
                try compile(node: s)
            }

        case is LetStatement:
            let letStmt = node as! LetStatement
            try compile(node: letStmt.value!)
            let symbol = symbolTable.define(name: letStmt.name.value)
            emit(op: .setGlobal, operands: [UInt16(symbol.index)])

        case is Identifier:
            let ident = node as! Identifier
            guard let symbol = symbolTable.resolve(name: ident.value) else {
                throw CompilerError.undefinedVariable(ident.value)
            }
            emit(op: .getGlobal, operands: [UInt16(symbol.index)])

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

        default:
            ()
        }
    }

    private func changedOperand(opPos: Int, operand: Int) {
        guard let op = Opcode(rawValue: instructions[opPos]) else {
            fatalError("Invalid opcode")
        }
        let newInstruction = make(op: op, operands: [UInt16(operand)])
        replaceInstruction(pos: opPos, newInstruction: newInstruction)
    }

    private func replaceInstruction(pos: Int, newInstruction: [UInt8]) {
        for i in 0..<newInstruction.count {
            instructions[pos + i] = newInstruction[i]
        }
    }

    private func lastInstructionIsPop() -> Bool {
        return lastInstruction?.opcode == .pop
    }

    private func removeLastPop() {
        guard let last = lastInstruction else { fatalError("No last instruction") }
        instructions = Array(instructions[..<last.position])
        lastInstruction = previousInstruction
    }

    func bytecode() -> Bytecode {
        return Bytecode(instructions: instructions, constants: constants)
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
        previousInstruction = lastInstruction
        lastInstruction = EmittedInstruction(opcode: op, position: Int(pos))

    }

    private func addInstruction(_ ins: [UInt8]) -> UInt16 {
        let posNewInstruction = instructions.count
        instructions += ins
        return UInt16(posNewInstruction)
    }
}

struct Bytecode {
    let instructions: Instructions
    let constants: [MonkeyObject]
}
