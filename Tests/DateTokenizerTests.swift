//
//  DateTokenizerTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 1/3/17.
//  Copyright © 2017 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

final class DateTokenizer: TokenizerType, DefaultTokenizerType {
    
    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?
    
    // public property
    
    required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }
    
    // formatters are expensive, so only instantiate once for all DateTokens
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()
    
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard _position < _template.unicodeScalars.endIndex else {
            // we've matched all of the template
            return false
        }
        
        switch (_template.unicodeScalars[_position], scalar) {
        case ("\u{0030}", CharacterSet.decimalDigits), // match with a decimal digit
             ("\u{002F}", "\u{002F}"):                 // match with the '/' character
            
            _position = _template.unicodeScalars.index(after: _position) // increment the template position
            _dateText.unicodeScalars.append(scalar) // add scalar to text matched so far
            return true
            
        default:
            return false
        }
    }
    
    func tokenIsComplete() -> Bool {
        if _position == _template.unicodeScalars.endIndex,
            let date = DateTokenizer.dateFormatter.date(from: _dateText) {
            // we've reached the end of the template
            // and the date text collected so far represents a valid
            // date format (e.g. not 99/99/99)
            
            _date = date
            return true
        }
        else {
            return false
        }
    }
    
    // reset the tokenizer for matching new date
    func prepareForReuse() {
        _dateText = ""
        _date = nil
        _position = _template.unicodeScalars.startIndex
    }
    
    struct DateToken: TokenType {
        let text: String
        let range: Range<String.Index>
        let date: Date
    }
    
    func makeToken(text: String, range: Range<String.Index>) -> DateToken {
        return DateToken(text: text, range: range, date: _date!)
    }
}

class DateTokenizerTests: XCTestCase {
    
    func testDateMatches() {
        
        let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/02/27 (Arrived) ref: 99/99/99"
        let tokens = messyInput.tokens(matchedWith: DateTokenizer())
        
        XCTAssert(tokens.count == 2, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].text == "12/01/27")
        XCTAssert(tokens[0].date == DateTokenizer.dateFormatter.date(from: tokens[0].text))
        
        XCTAssert(tokens[1].text == "12/02/27")
        XCTAssert(tokens[1].date == DateTokenizer.dateFormatter.date(from: tokens[1].text))
        
    }
}
