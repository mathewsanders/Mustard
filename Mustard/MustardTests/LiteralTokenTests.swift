//
//  InternalStateTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

class LiteralToken: TokenType {

    let target: String
    var position: String.UnicodeScalarIndex
    
    required convenience init() {
        self.init(target: "")
    }
    
    init(target: String = "") {
        self.target = target
        self.position = target.unicodeScalars.startIndex
    }
    
    func canAppend(next scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            return false
        }
        
        let targetScalar = target.unicodeScalars[position]
        if scalar == targetScalar {
            position = target.unicodeScalars.index(after: position)
            return true
        }
        else {
            return false
        }
    }
    
    func canCompleteWhenNextScalar(is scalar: UnicodeScalar) -> Bool {
        
        if position == target.unicodeScalars.endIndex && CharacterSet.whitespaces.contains(scalar) {
            position = target.unicodeScalars.startIndex
            return true
        }
        else {
            position = target.unicodeScalars.startIndex
            return false
        }
    }
}

extension String {
    var literalToken: LiteralToken {
        return LiteralToken(target: self)
    }
}

class LiteralTokenTests: XCTestCase {
    
    func testGetCatAndDuck() {
        
        let input = "the cat and the duck have a catastrophe"
        let tokens = input.tokens(from: "cat".literalToken, "duck".literalToken)
        
        XCTAssert(tokens.count == 2, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenType is LiteralToken)
        XCTAssert(tokens[0].text == "cat")
        
        XCTAssert(tokens[1].tokenType is LiteralToken)
        XCTAssert(tokens[1].text == "duck")
        
        print(tokens.count)
        print(input)
        for token in tokens {
            print("-", "'\(token.text)'")
        }
    }
}
