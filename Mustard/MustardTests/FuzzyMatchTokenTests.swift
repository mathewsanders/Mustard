//
//  FuzzyMatchTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

class FuzzyLiteralMatch: TokenType {
    
    required init() { }
    
    init(target: String) { }
    
    func canAppend(next scalar: UnicodeScalar) -> Bool {
        return false
    }
}

class FuzzyMatchTokenTests: XCTestCase {
    
    func testSpecialFormat() {
        
        let tokens = "Serial: #YF 1942-B 12/01/27 (Scanned)".tokens(from: FuzzyLiteralMatch(target: "#YF1942B"))
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenType is FuzzyLiteralMatch)
        XCTAssert(tokens[0].text == "#YF 1942-B")
        
    }
}
