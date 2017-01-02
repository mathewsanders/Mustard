// FallbackTokenizerTests.swift
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

class FallbackTokenizerTests: XCTestCase {
    
    func testFallback() {
        
        let input = "1.2 34 abc catastrophe cat 0.5"
        let matches = input.matches(from: NumberToken.tokenizer, "cat".literalToken, CharacterSet.letters)

        XCTAssert(matches.count == 6, "Unexpected number of tokens [\(matches.count)]")
        
        XCTAssert(matches[0].tokenizer is NumberToken)
        XCTAssert(matches[0].text == "1.2")
        
        XCTAssert(matches[1].tokenizer is NumberToken)
        XCTAssert(matches[1].text == "34")
        
        XCTAssert(matches[2].tokenizer is CharacterSet)
        XCTAssert(matches[2].text == "abc")
        
        XCTAssert(matches[3].tokenizer is CharacterSet)
        XCTAssert(matches[3].text == "catastrophe")
        
        XCTAssert(matches[4].tokenizer is LiteralToken)
        XCTAssert(matches[4].text == "cat")
        
        XCTAssert(matches[5].tokenizer is NumberToken)
        XCTAssert(matches[5].text == "0.5")
    }
}
