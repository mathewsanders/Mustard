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

enum MixedTokenizer: TokenizerType {
    
    case word
    case number
    case emoji
    case none // 'none' case not strictly needed, and
              // in this implementation will never be matched
    init() {
        self = .none
    }
    
    static let wordTokenizer = WordTokenizer()
    static let numberTokenizer = NumberTokenizer()
    static let emojiTokenizer = EmojiTokenizer()
    
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedTokenizer.wordTokenizer.tokenCanTake(scalar)
        case .number: return MixedTokenizer.numberTokenizer.tokenCanTake(scalar)
        case .emoji: return MixedTokenizer.emojiTokenizer.tokenCanTake(scalar)
        case .none:
            return false
        }
    }
    
    func token(startingWith scalar: UnicodeScalar) -> TokenizerType? {
        
        if let _ = MixedTokenizer.wordTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.word
        }
        else if let _ = MixedTokenizer.numberTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.number
        }
        else if let _ = MixedTokenizer.emojiTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.emoji
        }
        else {
            return nil
        }
    }
}

class MixedTokenTests: XCTestCase {
    
    func testMixedTokens() {
        
        let tokens: [MixedTokenizer.Token] = "123👩‍👩‍👦‍👦Hello world👶again👶🏿45.67".tokens()
        
        XCTAssert(tokens.count == 8, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenizer == .number)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].tokenizer == .emoji)
        XCTAssert(tokens[1].text == "👩‍👩‍👦‍👦")
        
        XCTAssert(tokens[2].tokenizer == .word)
        XCTAssert(tokens[2].text == "Hello")
        
        XCTAssert(tokens[3].tokenizer == .word)
        XCTAssert(tokens[3].text == "world")
    
        XCTAssert(tokens[4].tokenizer == .emoji)
        XCTAssert(tokens[4].text == "👶")
        
        XCTAssert(tokens[5].tokenizer == .word)
        XCTAssert(tokens[5].text == "again")
        
        XCTAssert(tokens[6].tokenizer == .emoji)
        XCTAssert(tokens[6].text == "👶🏿")
        
        XCTAssert(tokens[7].tokenizer == .number)
        XCTAssert(tokens[7].text == "45.67")
        
    }
}
