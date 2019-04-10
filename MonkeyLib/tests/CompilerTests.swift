//
//  CompilerTests.swift
//  MonkeyLibTests
//
//  Created by Rod Schmidt on 3/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class CompilerTests: XCTestCase {

    struct Test {
        let input: String
        let expectedConstants: [Any]
        let expectedInstructions: [Instructions]
    }

    override func setUp() {
    }

    override func tearDown() {
    }

    func testIntegerArithmetic() {
        let tests = [
            Test(input: "1 + 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .add, operands: []),
                    make(op: .pop, operands: [])
                ]
            ),
            Test(input: "1; 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .pop, operands: []),
                    make(op: .constant, operands: [1]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 - 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .sub, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 * 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .mul, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "2 / 1",
                 expectedConstants: [2, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .div, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushFalse, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 > 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .greaterThan, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 < 2",
                 expectedConstants: [2, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .greaterThan, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 == 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .equal, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "1 != 2",
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .notEqual, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true == false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pushFalse, operands: []),
                    make(op: .equal, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "true != false",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .pushFalse, operands: []),
                    make(op: .notEqual, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "-1",
                 expectedConstants: [1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .minus, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "!true",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .bang, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testConditionals() {
        let tests = [
            Test(input: "if (true) { 10 }; 3333;",
                 expectedConstants: [10, 3333] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .jumpNotTruthy, operands: [10]),
                    make(op: .constant, operands: [0]),
                    make(op: .jump, operands: [11]),
                    make(op: .null, operands: []),
                    make(op: .pop, operands: []),
                    make(op: .constant, operands: [1]),
                    make(op: .pop, operands: [])
                ]
            ),
            Test(input: "if (true) { 10 } else { 20 }; 3333;",
                 expectedConstants: [10, 20, 3333] as [Any],
                 expectedInstructions: [
                    make(op: .pushTrue, operands: []),
                    make(op: .jumpNotTruthy, operands: [10]),
                    make(op: .constant, operands: [0]),
                    make(op: .jump, operands: [13]),
                    make(op: .constant, operands: [1]),
                    make(op: .pop, operands: []),
                    make(op: .constant, operands: [2]),
                    make(op: .pop, operands: [])
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testGlobalLetStatements() {
        let tests = [
            Test(input: """
                    let one = 1;
                    let two = 2;
                    """,
                 expectedConstants: [1, 2] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .setGlobal, operands: [1]),
                ]
            ),
            Test(input: """
                    let one = 1;
                    one;
                    """,
                 expectedConstants: [1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .getGlobal, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: """
                    let one = 1;
                    let two = one;
                    two;
                    """,
                 expectedConstants: [1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .getGlobal, operands: [0]),
                    make(op: .setGlobal, operands: [1]),
                    make(op: .getGlobal, operands: [1]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testStringExpressions() {
        let tests = [
            Test(input: "\"monkey\"",
                 expectedConstants: ["monkey"] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [UInt16(0)]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "\"mon\" + \"key\"",
                 expectedConstants: ["mon", "key"] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .add, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testArrayLiterals() {
        let tests = [
            Test(input: "[]",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .array, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "[1, 2, 3]",
                 expectedConstants: [1, 2, 3] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .constant, operands: [2]),
                    make(op: .array, operands: [3]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "[1 + 2, 3 - 4, 5 * 6]",
                 expectedConstants: [1, 2, 3, 4, 5, 6] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .add, operands: []),
                    make(op: .constant, operands: [2]),
                    make(op: .constant, operands: [3]),
                    make(op: .sub, operands: []),
                    make(op: .constant, operands: [4]),
                    make(op: .constant, operands: [5]),
                    make(op: .mul, operands: []),
                    make(op: .array, operands: [3]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testHashLiterals() {
        let tests = [
            Test(input: "{}",
                 expectedConstants: [] as [Any],
                 expectedInstructions: [
                    make(op: .hash, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "{1: 2, 3: 4, 5: 6}",
                 expectedConstants: [1, 2, 3, 4, 5, 6] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .constant, operands: [2]),
                    make(op: .constant, operands: [3]),
                    make(op: .constant, operands: [4]),
                    make(op: .constant, operands: [5]),
                    make(op: .hash, operands: [6]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "{1: 2 + 3, 4: 5 * 6}",
                 expectedConstants: [1, 2, 3, 4, 5, 6] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .constant, operands: [2]),
                    make(op: .add, operands: []),
                    make(op: .constant, operands: [3]),
                    make(op: .constant, operands: [4]),
                    make(op: .constant, operands: [5]),
                    make(op: .mul, operands: []),
                    make(op: .hash, operands: [4]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testIndexExpressions() {
        let tests = [
            Test(input: "[1, 2, 3][1 + 1]",
                 expectedConstants: [1, 2, 3, 1, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .constant, operands: [2]),
                    make(op: .array, operands: [3]),
                    make(op: .constant, operands: [3]),
                    make(op: .constant, operands: [4]),
                    make(op: .add, operands: []),
                    make(op: .index, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "{1: 2}[2 - 1]",
                 expectedConstants: [1, 2, 2, 1] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .hash, operands: [2]),
                    make(op: .constant, operands: [2]),
                    make(op: .constant, operands: [3]),
                    make(op: .sub, operands: []),
                    make(op: .index, operands: []),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testCompilerScopes() {
        let compiler = Compiler()
        XCTAssertEqual(compiler.scopeIndex, 0)

        let globalSymbolTable = compiler.symbolTable

        compiler.emit(op: .mul, operands: [])

        compiler.enterScope()
        XCTAssertEqual(compiler.scopeIndex, 1)

        compiler.emit(op: .sub, operands: [])
        XCTAssertEqual(compiler.scopes[compiler.scopeIndex].instructions.count, 1)

        let last = compiler.scopes[compiler.scopeIndex].lastInstruction
        XCTAssertEqual(last?.opcode, .sub)

        XCTAssert(compiler.symbolTable.outer === globalSymbolTable)

        compiler.leaveScope()
        XCTAssertEqual(compiler.scopeIndex, 0)

        XCTAssert(compiler.symbolTable === globalSymbolTable)
        XCTAssertNil(compiler.symbolTable.outer)

        compiler.emit(op: .add, operands: [])
        XCTAssertEqual(compiler.scopes[compiler.scopeIndex].instructions.count, 2)

        let last2 = compiler.scopes[compiler.scopeIndex].lastInstruction
        XCTAssertEqual(last2?.opcode, .add)

        let previous = compiler.scopes[compiler.scopeIndex].previousInstruction
        XCTAssertEqual(previous?.opcode, .mul)
    }

    func testFunctions() {
        let tests = [
            Test(input: "fn() { return 5 + 10 }",
                 expectedConstants: [
                    5,
                    10,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .constant, operands: [1]),
                        make(op: .add, operands: []),
                        make(op: .returnValue, operands: [])
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [2]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "fn() { 5 + 10 }",
                 expectedConstants: [
                    5,
                    10,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .constant, operands: [1]),
                        make(op: .add, operands: []),
                        make(op: .returnValue, operands: [])
                    ]
                    ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [2]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "fn() { 1; 2 }",
                 expectedConstants: [
                    1,
                    2,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .pop, operands: []),
                        make(op: .constant, operands: [1]),
                        make(op: .returnValue, operands: [])
                    ]
                    ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [2]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testFunctionsWithoutReturnValue() {
        let tests = [
            Test(input: "fn() { }",
                 expectedConstants: [
                    [
                        make(op: .return, operands: []),
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testFunctionCalls() {
        let tests = [
            Test(input: "fn() { 24 }();",
                 expectedConstants: [
                    24,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .returnValue, operands: []),
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [1]),
                    make(op: .call, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "let noArg = fn() { 24 }; noArg();",
                 expectedConstants: [
                    24,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .returnValue, operands: []),
                    ]
                    ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [1]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .getGlobal, operands: [0]),
                    make(op: .call, operands: [0]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "let oneArg = fn(a) { a }; oneArg(24);",
                 expectedConstants: [
                    [
                        make(op: .getLocal, operands: [0]),
                        make(op: .returnValue, operands: []),
                    ],
                    24,
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .getGlobal, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .call, operands: [1]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "let manyArg = fn(a, b, c) { a; b; c}; manyArg(24, 25, 26);",
                 expectedConstants: [
                    [
                        make(op: .getLocal, operands: [0]),
                        make(op: .pop, operands: []),
                        make(op: .getLocal, operands: [1]),
                        make(op: .pop, operands: []),
                        make(op: .getLocal, operands: [2]),
                        make(op: .returnValue, operands: []),
                    ],
                    24,
                    25,
                    26
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .getGlobal, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .constant, operands: [2]),
                    make(op: .constant, operands: [3]),
                    make(op: .call, operands: [3]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func testLetStatementScopes() {
        let tests = [
            Test(input: "let num = 55; fn() { num }",
                 expectedConstants: [
                    55,
                    [
                        make(op: .getGlobal, operands: [0]),
                        make(op: .returnValue, operands: []),
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [0]),
                    make(op: .setGlobal, operands: [0]),
                    make(op: .constant, operands: [1]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "fn() { let num = 55; num }",
                 expectedConstants: [
                    55,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .setLocal, operands: [0]),
                        make(op: .getLocal, operands: [0]),
                        make(op: .returnValue, operands: []),
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [1]),
                    make(op: .pop, operands: []),
                ]
            ),
            Test(input: "fn() { let a = 55; let b = 77; a + b }",
                 expectedConstants: [
                    55,
                    77,
                    [
                        make(op: .constant, operands: [0]),
                        make(op: .setLocal, operands: [0]),
                        make(op: .constant, operands: [1]),
                        make(op: .setLocal, operands: [1]),
                        make(op: .getLocal, operands: [0]),
                        make(op: .getLocal, operands: [1]),
                        make(op: .add, operands: []),
                        make(op: .returnValue, operands: []),
                    ]
                 ] as [Any],
                 expectedInstructions: [
                    make(op: .constant, operands: [2]),
                    make(op: .pop, operands: []),
                ]
            ),
        ]

        runCompilerTests(tests)
    }

    func runCompilerTests(_ tests: [Test]) {
        for t in tests {
            let program = parse(input: t.input)
            let compiler = Compiler()
            try? compiler.compile(node: program)

            let bytecode = compiler.bytecode()
            XCTAssertInstructions(t.expectedInstructions, bytecode.instructions)
            XCTAssertConstants(t.expectedConstants, bytecode.constants)
        }
    }

    private func parse(input: String) -> Program {
        let l = Lexer(input: input)
        let p = Parser(lexer: l)
        return p.parseProgram()!
    }

    func XCTAssertInstructions(_ expected: [Instructions], _ actual: Instructions, file: StaticString = #file, line: UInt = #line) {
        let concatted = concatInstructions(expected)
        XCTAssertEqual(actual.count, concatted.count, file: file, line: line)

        for (i, ins) in concatted.enumerated() {
            XCTAssertEqual(actual[i], ins, file: file, line: line)
        }
    }

    private func concatInstructions(_ s: [Instructions]) -> Instructions {
        return s.reduce([], +)
    }

    func XCTAssertConstants(_ expected: [Any], _ actual: [MonkeyObject], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(expected.count, actual.count, file: file, line: line)

        for (i, constant) in expected.enumerated() {
            switch constant {
            case is Int:
                XCTAssertIntegerObject(Int64(constant as! Int), actual[i])

            case is String:
                XCTAssertStringObject(constant as! String, actual[i])

            case is [Instructions]:
                let fn = actual[i] as? CompiledFunction
                XCTAssertNotNil(fn, "constant \(i) is not a function: \(actual[i])")
                XCTAssertInstructions(constant as! [Instructions], fn!.instructions)

            default:
                XCTFail()
            }
        }
    }

    func XCTAssertIntegerObject(_ expected: Int64, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyInteger
        XCTAssertNotNil(result, file: file, line: line)
        XCTAssertEqual(result?.value, Int(expected), file: file, line: line)
    }

    func XCTAssertStringObject(_ expected: String, _ actual: MonkeyObject, file: StaticString = #file, line: UInt = #line) {
        let result = actual as? MonkeyString
        XCTAssertNotNil(result, file: file, line: line)
        XCTAssertEqual(result?.value, expected, file: file, line: line)
    }

}
