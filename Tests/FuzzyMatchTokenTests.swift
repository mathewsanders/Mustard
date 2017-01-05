// FuzzyMatchTokenTests.swift
//
// Copyright (c) 2017 Mathew Sanders
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import XCTest
import Mustard

infix operator ~=
func ~= (option: CharacterSet, input: UnicodeScalar) -> Bool {
    return option.contains(input)
}

class FuzzyLiteralMatch: TokenizerType {
    
    let target: String
    private let exclusions: CharacterSet
    private var position: String.UnicodeScalarIndex
    
    init(target: String, ignoring exclusions: CharacterSet) {
        self.target = target
        self.position = target.unicodeScalars.startIndex
        self.exclusions = exclusions
    }
    
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            return false // we've matched all of the target
        }
        
        let targetScalar = target.unicodeScalars[position]
        
        switch (scalar, targetScalar) {
         
        // following 3 cases check either that scalar and target scalar are exactly the same
        // or the equivilant upper/lowercase pair
        case (_, _) where scalar == targetScalar:
            incrementPosition()
            return true
            
        case (CharacterSet.lowercaseLetters, CharacterSet.uppercaseLetters) where scalar.value - targetScalar.value == 32:
            incrementPosition()
            return true
            
        case (CharacterSet.uppercaseLetters, CharacterSet.lowercaseLetters) where targetScalar.value - scalar.value == 32:
            incrementPosition()
            return true
        
        case (exclusions, _)
            where position > target.unicodeScalars.startIndex:
            // scalar matches character from exclusions charater set
            return true
            
        default:
            // scalar isn't the next target scalar, or a scalar that can be ignored
            return false
        }
    }
    
    private func incrementPosition() {
        position = target.unicodeScalars.index(after: position)
    }
    
    var tokenIsComplete: Bool {
        return position == target.unicodeScalars.endIndex
    }
    
    func prepareForReuse() {
        position = target.unicodeScalars.startIndex
    }
}


class FuzzyMatchTokenTests: XCTestCase {
    
    func testSpecialFormat() {
        
        let fuzzyTokenzier = FuzzyLiteralMatch(target: "#YF1942B",
                                               ignoring: CharacterSet.whitespaces.union(.punctuationCharacters)).anyTokenizer
        
        let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/02/27 (Arrived) ref: 99/99/99"
        let tokens = messyInput.tokens(matchedWith: fuzzyTokenzier)
        
        XCTAssert(tokens.count == 1, "Unexpected number of tokens [\(tokens.count)]")
        XCTAssert(tokens[0].text == "#YF 1942-b")
    }
}


