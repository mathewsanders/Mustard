//
//  CharacterSetTokenTests.swift
//  MustardTests
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Foundation
import Mustard

infix operator ==
fileprivate func == (option: TokenType, input: CharacterSet) -> Bool {
    if let characterSet = option as? CharacterSet {
        return characterSet == input
    }
    return false
}

class CharacterSetTokenTests: XCTestCase {
    
    func testCharacterSetTokenizer() {
                
        let tokens = "123Hello world&^45.67".tokens(from: .decimalDigits, .letters)
        
        let numbers = tokens.filter({ $0.tokenizer is NumberToken })
        
        XCTAssert(tokens.count == 5, "Unexpected number of characterset tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].tokenizer == CharacterSet.letters)
        XCTAssert(tokens[1].text == "Hello")
        
        XCTAssert(tokens[2].tokenizer == CharacterSet.letters)
        XCTAssert(tokens[2].text == "world")
        
        XCTAssert(tokens[3].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[3].text == "45")
        
        XCTAssert(tokens[4].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[4].text == "67")
        
    }
}
