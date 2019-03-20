//
//  ObjectTests.swift
//  Monkey
//
//  Created by Rod Schmidt on 3/17/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import XCTest
@testable import MonkeyLib

class ObjectTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStringHashKey() {
        let hello1 = MonkeyString(value: "Hello World")
        let hello2 = MonkeyString(value: "Hello World")
        let diff1 = MonkeyString(value: "My name is johnny")
        let diff2 = MonkeyString(value: "My name is johnny")

        XCTAssertEqual(hello1.hashKey(), hello2.hashKey())
        XCTAssertEqual(diff1.hashKey(), diff2.hashKey())
    }

    func testIntegerHashKey() {
        let hello1 = MonkeyInteger(value: 1)
        let hello2 = MonkeyInteger(value: 1)
        let diff1 = MonkeyInteger(value: 2)
        let diff2 = MonkeyInteger(value: 2)

        XCTAssertEqual(hello1.hashKey(), hello2.hashKey())
        XCTAssertEqual(diff1.hashKey(), diff2.hashKey())
    }

    func testBooleanHashKey() {
        let hello1 = MonkeyBoolean(value: false)
        let hello2 = MonkeyBoolean(value: false)
        let diff1 = MonkeyBoolean(value: true)
        let diff2 = MonkeyBoolean(value: true)

        XCTAssertEqual(hello1.hashKey(), hello2.hashKey())
        XCTAssertEqual(diff1.hashKey(), diff2.hashKey())
    }

}
