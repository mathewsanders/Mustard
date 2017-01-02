// InternalStateTokenTests.swift
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

// implementing as class rather than struct since `canTake(_:)` will have mutating effect.
class LiteralToken: TokenType {

    private let target: String
    private var position: String.UnicodeScalarIndex
    
    // required by the TokenType protocol, but non-sensical to use
    required convenience init() {
        self.init(target: "")
    }
    
    // instead, we should initalize instance with the target String we're looking for
    init(target: String) {
        self.target = target
        self.position = target.unicodeScalars.startIndex
    }
    
    // instead of looking at a set of scalars, the order that the scalar occurs 
    // is relevent for the token
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            return false
        }
        
        // if the scalar matches the target scalar in the current position, then advance 
        // the position and return true
        if scalar == target.unicodeScalars[position] {
            position = target.unicodeScalars.index(after: position)
            return true
        }
        else {
            return false
        }
    }
    
    // this token is only complete when we've called `canTake(_:)` with the correct sequence
    // of scalars such that `position` has advanced to the endIndex of the target
    var isComplete: Bool {
        return position == target.unicodeScalars.endIndex
    }
    
    // if we've matched the token completely, it should be invalid if the next scalar 
    // matches a letter, this means that literal match of "cat" will not match "catastrophe"
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        
        if let next = scalar {
            return CharacterSet.letters.contains(next)
        }
        else {
            return false
        }
    }
    
    // token instances are re-used, in most cases this doesn't matter, but because we keep
    // an internal state, we need to reset this instance to start matching again
    func prepareForReuse() {
        position = target.unicodeScalars.startIndex
    }
}

extension String {
    // a convenience to allow us to use `"cat".literalToken` instead of `LiteralToken("cat")`
    var literalToken: LiteralToken {
        return LiteralToken(target: self)
    }
}


class LiteralTokenTests: XCTestCase {
    
    func testGetCatAndDuck() {
        
        let input = "the cat and the catastrophe duck"
        let matches = input.matches(from: "cat".literalToken, "duck".literalToken)
        
        XCTAssert(matches.count == 2, "Unexpected number of matches [\(matches.count)]")
        
        XCTAssert(matches[0].tokenizer is LiteralToken)
        XCTAssert(matches[0].text == "cat")
        
        XCTAssert(matches[1].tokenizer is LiteralToken)
        XCTAssert(matches[1].text == "duck")
        
    }
}
