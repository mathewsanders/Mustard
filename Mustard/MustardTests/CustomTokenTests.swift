//
//  CustomTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

struct NumberToken: TokenType {
    
    static private let characters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
    
    // number token can include any character in 0...9 + '.'
    func tokenCanInclude(scalar: UnicodeScalar) -> Bool {
        return NumberToken.characters.contains(scalar)
    }
    
    // numbers must start with character 0...9
    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType? {
        guard CharacterSet.decimalDigits.contains(scalar) else {
            return nil
        }
        return NumberToken()
    }
}

struct WordToken: TokenType {
    
    // word token can include any character in a...z
    func tokenCanInclude(scalar: UnicodeScalar) -> Bool {
        return CharacterSet.letters.contains(scalar)
    }
    
    // word token must start with character a...z
    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType? {
        guard CharacterSet.letters.contains(scalar) else {
            return nil
        }
        return WordToken()
    }
}

class CustomTokenTests: XCTestCase {
    
    func testNumberToken() {
        
        let tokens = "123Hello world&^45.67".tokens(from: NumberToken.tokenizer, WordToken.tokenizer)
        
        XCTAssert(tokens.count == 4, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenType is NumberToken)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].tokenType is WordToken)
        XCTAssert(tokens[1].text == "Hello")
        
        XCTAssert(tokens[2].tokenType is WordToken)
        XCTAssert(tokens[2].text == "world")
        
        XCTAssert(tokens[3].tokenType is NumberToken)
        XCTAssert(tokens[3].text == "45.67")
    }
}


