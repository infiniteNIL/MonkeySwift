//
//  vm.swift
//  Monkey
//
//  Created by Rod Schmidt on 4/5/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

private let StackSize = 2048

enum MonkeyVMError: Error {
    case stackOverflow
}

class MonkeyVM {
    let constants: [MonkeyObject]
    let instructions: Instructions
    var stack: [MonkeyObject]
    var sp: Int // Always points to the next value. Top of stack is stack[sp-1]

    init(bytecode: Bytecode) {
        instructions = bytecode.instructions
        constants = bytecode.constants
        stack = [MonkeyObject](repeating: MonkeyNull(), count: StackSize)
        sp = 0
    }

    func stackTop() -> MonkeyObject? {
        if sp == 0 { return nil }
        return stack[sp - 1]
    }

    func run() throws {
        var ip = 0
        while ip < instructions.count {
            guard let op = Opcode(rawValue: instructions[ip]) else {
                fatalError("Invalid opcode passed to VM")
            }

            switch op {
            case .constant:
                let bytes = Array(instructions[(ip + 1)...])
                let constIndex = Int(readUInt16(bytes))
                ip += 2
                try push(constants[constIndex])

            case .add:
                let right = pop()
                let left = pop()
                let leftValue = (left as! MonkeyInteger).value
                let rightValue = (right as! MonkeyInteger).value
                let result = leftValue + rightValue
                try push(MonkeyInteger(value: result))
            }

            ip += 1
        }
    }

    private func push(_ o: MonkeyObject) throws {
        guard sp < StackSize else { throw MonkeyVMError.stackOverflow }

        stack[sp] = o
        sp += 1
    }

    private func pop() -> MonkeyObject {
        let o = stack[sp - 1]
        sp -= 1
        return o
    }
}
