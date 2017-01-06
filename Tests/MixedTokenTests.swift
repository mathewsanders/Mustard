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

final class MixedTokenizer: TokenizerType, DefaultTokenizerType {
    
    enum Mode {
        case word
        case number
        case emoji
        case none
    }
    
    var mode: Mode
    
    init() {
        mode = .none
    }
    
    static let wordTokenizer = WordTokenizer.defaultTokenzier
    static let numberTokenizer = NumberTokenizer.defaultTokenzier
    static let emojiTokenizer = EmojiTokenizer.defaultTokenzier
    
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        switch mode {
        case .word: return MixedTokenizer.wordTokenizer.tokenCanTake(scalar)
        case .number: return MixedTokenizer.numberTokenizer.tokenCanTake(scalar)
        case .emoji: return MixedTokenizer.emojiTokenizer.tokenCanTake(scalar)
        case .none: return false
        }
    }
    
    func tokenizerStartingWith(_ scalar: UnicodeScalar) -> AnyTokenizer? {
        
        if let _ = MixedTokenizer.wordTokenizer.tokenizerStartingWith(scalar) {
            self.mode = .word
            return self.anyTokenizer
        }
        else if let _ = MixedTokenizer.numberTokenizer.tokenizerStartingWith(scalar) {
            self.mode = .number
            return self.anyTokenizer
        }
        else if let _ = MixedTokenizer.emojiTokenizer.tokenizerStartingWith(scalar) {
            self.mode = .emoji
            return self.anyTokenizer
        }
        else {
            self.mode = .none
            return nil
        }
    }
    
    struct MixedToken: TokenType {
        let text: String
        let range: Range<String.Index>
        let mode: Mode
    }
    
    func makeToken(text: String, range: Range<String.Index>) -> MixedToken {
        return MixedToken(text: text, range: range, mode: mode)
    }
}

class MixedTokenTests: XCTestCase {
    
    func testMixedTokens() {
        
        let tokens = "123👩‍👩‍👦‍👦Hello world👶again👶🏿45.67".tokens(matchedWith: MixedTokenizer())
        
        XCTAssert(tokens.count == 8, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].mode == .number)
        XCTAssert(tokens[0].text == "123")
        
        XCTAssert(tokens[1].mode == .emoji)
        XCTAssert(tokens[1].text == "👩‍👩‍👦‍👦")
        
        XCTAssert(tokens[2].mode == .word)
        XCTAssert(tokens[2].text == "Hello")
        
        XCTAssert(tokens[3].mode == .word)
        XCTAssert(tokens[3].text == "world")
    
        XCTAssert(tokens[4].mode == .emoji)
        XCTAssert(tokens[4].text == "👶")
        
        XCTAssert(tokens[5].mode == .word)
        XCTAssert(tokens[5].text == "again")
        
        XCTAssert(tokens[6].mode == .emoji)
        XCTAssert(tokens[6].text == "👶🏿")
        
        XCTAssert(tokens[7].mode == .number)
        XCTAssert(tokens[7].text == "45.67")
        
    }
}
