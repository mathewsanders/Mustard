// MixedTokenTests.swift
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

enum MixedToken: TokenType {
    
    case word
    case number
    case emoji
    case none
    
    init() {
        self = .none
    }
    
    static let wordToken = WordToken()
    static let numberToken = NumberToken()
    static let emojiToken = EmojiToken()
    
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedToken.wordToken.canTake(scalar)
        case .number: return MixedToken.numberToken.canTake(scalar)
        case .emoji: return MixedToken.emojiToken.canTake(scalar)
        case .none:
            return false
        }
    }
    
    func token(startingWith scalar: UnicodeScalar) -> TokenType? {
        
        if let _ = MixedToken.wordToken.token(startingWith: scalar) {
            return MixedToken.word
        }
        else if let _ = MixedToken.numberToken.token(startingWith: scalar) {
            return MixedToken.number
        }
        else if let _ = MixedToken.emojiToken.token(startingWith: scalar) {
            return MixedToken.emoji
        }
        else {
            return nil
        }
    }
}

class MixedTokenTests: XCTestCase {
    
    func testMixedTokens() {
        
        let matches: [MixedToken.Match] = "123👩‍👩‍👦‍👦Hello world👶again👶🏿45.67".matches()
        
        XCTAssert(matches.count == 8, "Unexpected number of matches [\(matches.count)]")
        
        XCTAssert(matches[0].tokenizer == .number)
        XCTAssert(matches[0].text == "123")
        
        XCTAssert(matches[1].tokenizer == .emoji)
        XCTAssert(matches[1].text == "👩‍👩‍👦‍👦")
        
        XCTAssert(matches[2].tokenizer == .word)
        XCTAssert(matches[2].text == "Hello")
        
        XCTAssert(matches[3].tokenizer == .word)
        XCTAssert(matches[3].text == "world")
    
        XCTAssert(matches[4].tokenizer == .emoji)
        XCTAssert(matches[4].text == "👶")
        
        XCTAssert(matches[5].tokenizer == .word)
        XCTAssert(matches[5].text == "again")
        
        XCTAssert(matches[6].tokenizer == .emoji)
        XCTAssert(matches[6].text == "👶🏿")
        
        XCTAssert(matches[7].tokenizer == .number)
        XCTAssert(matches[7].text == "45.67")
        
    }
}
