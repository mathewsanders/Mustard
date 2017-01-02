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

struct NumberTokenizer: TokenizerType {
    
    static private let numberCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))
    
    // numbers must start with character 0...9
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return CharacterSet.decimalDigits.contains(scalar)
    }
    
    // number token can include any character in 0...9 + '.'
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return NumberTokenizer.numberCharacters.contains(scalar)
    }
}

struct WordTokenizer: TokenizerType {

    // word token can include any character in a...z + A...Z
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return CharacterSet.letters.contains(scalar)
    }
}

class CustomTokenTests: XCTestCase {
    
    func testNumberToken() {
        
        let tokens = "123Hello world&^45.67".tokens(matchedWith: NumberTokenizer.defaultTokenzier, WordTokenizer.defaultTokenzier)
        
        XCTAssert(tokens.count == 4, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenizer is NumberTokenizer)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].tokenizer is WordTokenizer)
        XCTAssert(tokens[1].text == "Hello")
        
        XCTAssert(tokens[2].tokenizer is WordTokenizer)
        XCTAssert(tokens[2].text == "world")
        
        XCTAssert(tokens[3].tokenizer is NumberTokenizer)
        XCTAssert(tokens[3].text == "45.67")
    }
}

