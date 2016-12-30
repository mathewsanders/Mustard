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
        
        XCTAssert(tokens.count == 5, "Unexpected number of characterset tokens")
        
        XCTAssert(tokens[0].tokenType == CharacterSet.decimalDigits)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].tokenType == CharacterSet.letters)
        XCTAssert(tokens[1].text == "Hello")
        
        XCTAssert(tokens[2].tokenType == CharacterSet.letters)
        XCTAssert(tokens[2].text == "world")
        
        XCTAssert(tokens[3].tokenType == CharacterSet.decimalDigits)
        XCTAssert(tokens[3].text == "45")
        
        XCTAssert(tokens[4].tokenType == CharacterSet.decimalDigits)
        XCTAssert(tokens[4].text == "67")
        
    }
}
