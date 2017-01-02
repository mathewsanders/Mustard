//
//  FallbackTokenizerTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 1/1/17.
//  Copyright © 2017 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

class FallbackTokenizerTests: XCTestCase {
    
    func testFallback() {
        
        let input = "1.2 34 abc catastrophe cat 0.5"
        let tokens = input.tokens(from: NumberToken.tokenizer, "cat".literalToken, CharacterSet.letters)

        XCTAssert(tokens.count == 6, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenizer is NumberToken)
        XCTAssert(tokens[0].text == "1.2")
        
        XCTAssert(tokens[1].tokenizer is NumberToken)
        XCTAssert(tokens[1].text == "34")
        
        XCTAssert(tokens[2].tokenizer is CharacterSet)
        XCTAssert(tokens[2].text == "abc")
        
        XCTAssert(tokens[3].tokenizer is CharacterSet)
        XCTAssert(tokens[3].text == "catastrophe")
        
        XCTAssert(tokens[4].tokenizer is LiteralToken)
        XCTAssert(tokens[4].text == "cat")
        
        XCTAssert(tokens[5].tokenizer is NumberToken)
        XCTAssert(tokens[5].text == "0.5")
    }
}
