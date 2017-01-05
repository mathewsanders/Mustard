// CharacterSetTokenTests.swift
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

infix operator ==
fileprivate func == (option: CharacterSet.Token, input: CharacterSet) -> Bool {
    
    return input == option.set
}

class CharacterSetTokenTests: XCTestCase {
    
    func testCharacterSetTokenizer() {
                
        let tokens = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)
        
        XCTAssert(tokens.count == 5, "Unexpected number of tokens [\(tokens.count)]")
        
        //XCTAssert(tokens[0].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[0].text == "123")
        
        //XCTAssert(tokens[1].tokenizer == CharacterSet.letters)
        XCTAssert(tokens[1].text == "Hello")
        
        //XCTAssert(tokens[2].tokenizer == CharacterSet.letters)
        XCTAssert(tokens[2].text == "world")
        
        //XCTAssert(tokens[3].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[3].text == "45")
        
        //XCTAssert(tokens[4].tokenizer == CharacterSet.decimalDigits)
        XCTAssert(tokens[4].text == "67")
        
    }
}
