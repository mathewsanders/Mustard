// EmojiTokenTests.swift
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

struct EmojiTokenizer: TokenizerType, DefaultTokenizerType {
    
    // (e.g. can't start with a ZWJ)
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return EmojiTokenizer.isEmojiScalar(scalar)
    }
    
    // either in the known range for a emoji, or a ZWJ
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return EmojiTokenizer.isEmojiScalar(scalar) || EmojiTokenizer.isJoiner(scalar)
    }
    
    static func isJoiner(_ scalar: UnicodeScalar) -> Bool {
        return scalar == "\u{200D}" // Zero-width joiner
    }
    
    static func isEmojiScalar(_ scalar: UnicodeScalar) -> Bool {
        
        switch scalar {
        case
        "\u{0001F600}"..."\u{0001F64F}", // Emoticons
        "\u{0001F300}"..."\u{0001F5FF}", // Misc Symbols and Pictographs
        "\u{0001F680}"..."\u{0001F6FF}", // Transport and Map
        "\u{00002600}"..."\u{000026FF}", // Misc symbols
        "\u{00002700}"..."\u{000027BF}", // Dingbats
        "\u{0000FE00}"..."\u{0000FE0F}", // Variation Selectors
        "\u{0001F900}"..."\u{0001F9FF}", // Various (e.g. 🤖)
        "\u{0001F1E6}"..."\u{0001F1FF}": // regional flags
            return true
            
        default:
            return false
        }
    }
}

class EmojiTokenTests: XCTestCase {
    
    func testEmojiToken() {
        
        // Note:
        // "👶".unicodeScalars.count 
        // -> 1
        //
        // "👶🏿".unicodeScalars.count 
        // -> 2 (base + skin tone modifier)
        //
        // "🇳🇿".unicodeScalars.count 
        // -> 2 (regional indicator symbols e.g. NZ flag is [🇳,🇿] \u{0001F1F3}\u{0001F1FF}
        //
        // "🏳️‍🌈".unicodeScalars.count
        // -> 4 (🏳️‍ (3 scalars) and 🌈 (1 scalar))
        //
        // "👩‍👩‍👦‍👦".unicodeScalars.count
        // -> 7 (4 base, combied with 3 zero-width joiners \u{200D})
        
        let sample = "baby:👶 baby:👶🏿 flag:🇳🇿 flag:🏳️‍🌈 family:👩‍👩‍👦‍👦"
        let tokens: [EmojiTokenizer.Token] = sample.tokens()
        
        XCTAssert(tokens.count == 5, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].text == "👶")
        XCTAssert(tokens[1].text == "👶🏿")
        XCTAssert(tokens[2].text == "🇳🇿")
        XCTAssert(tokens[3].text == "🏳️‍🌈")
        XCTAssert(tokens[4].text == "👩‍👩‍👦‍👦")
        
    }
}
