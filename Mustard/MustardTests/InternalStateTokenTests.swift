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

    let target = "and"
    var position: String.UnicodeScalarIndex
    
    required init() {
        print("LiteralToken.init")
        position = target.unicodeScalars.startIndex
    }
    
    func canInclude(scalar: UnicodeScalar) -> Bool {
        
        print("canInclude(scalar", scalar)
        
        guard position < target.unicodeScalars.endIndex else {
            return false
        }
        
        let currentScalar = target.unicodeScalars[position]
        if scalar == currentScalar {
            position = target.unicodeScalars.index(after: position)
            return true
        }
        else {
            position = target.unicodeScalars.startIndex
            return false
        }
    }
}

class InternalStateTokenTests: XCTestCase {
    
    func testExample() {
        
        let tokens = "The cat and the hat".tokens(from: LiteralToken.tokenizer)
        
        print(tokens.count)
        
        for token in tokens {
            print(token.text)
        }
        
    }
    
}
