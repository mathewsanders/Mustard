
//
//  EmojiTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

struct EmojiToken: TokenType {
    
    // (e.g. can't start with a ZWJ)
    func canStart(with scalar: UnicodeScalar) -> Bool {
        return EmojiToken.isEmojiScalar(scalar)
    }
    
    // either in the known range for a emoji, or a ZWJ
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        return EmojiToken.isEmojiScalar(scalar) || EmojiToken.isJoiner(scalar)
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
        let tokens = sample.tokens(from: EmojiToken.tokenizer)
        
        XCTAssert(tokens.count == 5, "Unexpected number of emoji tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].text == "👶")
        XCTAssert(tokens[1].text == "👶🏿")
        XCTAssert(tokens[2].text == "🇳🇿")
        XCTAssert(tokens[3].text == "🏳️‍🌈")
        XCTAssert(tokens[4].text == "👩‍👩‍👦‍👦")
        
    }
}
