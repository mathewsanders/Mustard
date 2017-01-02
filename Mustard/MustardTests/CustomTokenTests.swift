// CustomTokenTests.swift
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

struct NumberToken: TokenType {
    
    static private let numberCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
    
    // numbers must start with character 0...9
    func canStart(with scalar: UnicodeScalar) -> Bool {
        return CharacterSet.decimalDigits.contains(scalar)
    }
    
    // number token can include any character in 0...9 + '.'
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        return NumberToken.numberCharacters.contains(scalar)
    }
}

struct WordToken: TokenType {

    // word token can include any character in a...z + A...Z
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.letters.contains(scalar)
    }
}

class CustomTokenTests: XCTestCase {
    
    func testNumberToken() {
        
        let matches = "123Hello world&^45.67".matches(from: NumberToken.tokenizer, WordToken.tokenizer)
        
        XCTAssert(matches.count == 4, "Unexpected number of matches [\(matches.count)]")
        
        XCTAssert(matches[0].tokenizer is NumberToken)
        XCTAssert(matches[0].text == "123")
        
        XCTAssert(matches[1].tokenizer is WordToken)
        XCTAssert(matches[1].text == "Hello")
        
        XCTAssert(matches[2].tokenizer is WordToken)
        XCTAssert(matches[2].text == "world")
        
        XCTAssert(matches[3].tokenizer is NumberToken)
        XCTAssert(matches[3].text == "45.67")
    }
}

