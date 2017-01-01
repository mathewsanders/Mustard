//
//  FuzzyMatchTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

infix operator ~=
func ~= (option: CharacterSet, input: UnicodeScalar) -> Bool {
    return option.contains(input)
}

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
    
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            // we've matched all of the target
            return false
        }
        
        let targetScalar = target.unicodeScalars[position]
        
        switch (scalar, targetScalar) {
        case (_, _)
                where scalar == targetScalar,
             (CharacterSet.lowercaseLetters, CharacterSet.uppercaseLetters)
                where scalar.value - targetScalar.value == 32,
             (CharacterSet.uppercaseLetters, CharacterSet.lowercaseLetters)
                where targetScalar.value - scalar.value == 32:
            // scalar and target scalar are either an exact match,
            // or equivilant upper/lowercase pair
            // advance the position and return true
            position = target.unicodeScalars.index(after: position)
            return true
        
        case (exclusions, _)
            where position > target.unicodeScalars.startIndex:
            // if:
            // - we've matched at least one of the target scalars; and
            // - this scalar matches a scalar that's can be ignored
            // then:
            // - return true without advancing the position
            return true
            
        default:
            // scalar isn't the next target scalar, or a scalar that can be ignored
            return false
        }
    }
    
    var isComplete: Bool {
        return position == target.unicodeScalars.endIndex
    }
    
    func prepareForReuse() {
        position = target.unicodeScalars.startIndex
    }
}

class DateMatch: TokenType {
    
    let template = "00/00/00"
    var position: String.UnicodeScalarIndex
    
    required init() {
        position = template.unicodeScalars.startIndex
    }
    
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard position < template.unicodeScalars.endIndex else {
            // we've matched all of the template
            return false
        }
        
        switch (template.unicodeScalars[position], scalar) {
        case ("\u{0030}", CharacterSet.decimalDigits), // match with a decimal digit
             ("\u{002F}", "\u{002F}"):                 // match with the '/' character
            
            position = template.unicodeScalars.index(after: position)
            return true
            
        default:
            return false
        }
    }
    
    var isComplete: Bool {
        return position == template.unicodeScalars.endIndex
    }
    
    func prepareForReuse() {
        position = template.unicodeScalars.startIndex
    }
}

class FuzzyMatchTokenTests: XCTestCase {
    
    func testSpecialFormat() {
        
        let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned)"
        
        let fuzzyTokenzier = FuzzyLiteralMatch(target: "#YF1942B",
                                               ignoring: CharacterSet.whitespaces.union(.punctuationCharacters))
        
        let tokens = messyInput.tokens(from: fuzzyTokenzier, DateMatch.tokenizer)
        
        XCTAssert(tokens.count == 2, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenType is FuzzyLiteralMatch)
        XCTAssert(tokens[0].text == "#YF 1942-b")
        
        XCTAssert(tokens[1].tokenType is DateMatch)
        XCTAssert(tokens[1].text == "12/01/27")
        
    }
}
