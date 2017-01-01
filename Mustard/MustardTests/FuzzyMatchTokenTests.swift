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
    
    let target: String
    let exclusions: CharacterSet
    var position: String.UnicodeScalarIndex
    
    required convenience init() {
        self.init(target: "", ignoring: CharacterSet.whitespaces)
    }
    
    init(target: String, ignoring exclusions: CharacterSet) {
        self.target = target
        self.position = target.unicodeScalars.startIndex
        self.exclusions = exclusions
    }
    
    func canAppend(next scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            // we've matched all of the target
            return false
        }
        
        if scalar == target.unicodeScalars[position] {
            // scalar matches the next target scalar!
            // advance the position and return true
            position = target.unicodeScalars.index(after: position)
            return true
        }
        
        else if position > target.unicodeScalars.startIndex && exclusions.contains(scalar) {
            // if: 
            // - we've matched at least one of the target scalars; and
            // - this scalar matches a scalar that's can be ignored
            // then:
            // - return true without advancing the position
            return true
        }
        else {
            // scalar isn't the next target scalar, or a scalar that can be ignored
            return false
        }
    }
    
    func canCompleteWhenNextScalar(is scalar: UnicodeScalar) -> Bool {
        
        if position == target.unicodeScalars.endIndex {
            resetToken()
            return true
        }
        else {
            resetToken()
            return false
        }
    }
    
    private func resetToken() {
        position = target.unicodeScalars.startIndex
    }
}

class FuzzyMatchTokenTests: XCTestCase {
    
    func testSpecialFormat() {
        
        let messyInput = "Serial: #YF 1942-B 12/01/27 (Scanned)"
        let fuzzyTokenzier = FuzzyLiteralMatch(target: "#YF1942B",
                                               ignoring: CharacterSet.whitespaces.union(.punctuationCharacters))
        
        let tokens = messyInput.tokens(from: fuzzyTokenzier)
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenType is FuzzyLiteralMatch)
        XCTAssert(tokens[0].text == "#YF 1942-B")
        
    }
}
