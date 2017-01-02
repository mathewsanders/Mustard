//
//  FuzzyMatchTokenTests.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

infix operator ~=
func ~= (option: CharacterSet, input: UnicodeScalar) -> Bool {
    return option.contains(input)
}

class FuzzyLiteralMatch: TokenType {
    
    let target: String
    private let exclusions: CharacterSet
    private var position: String.UnicodeScalarIndex
    
    required convenience init() {
        self.init(target: "", ignoring: CharacterSet.whitespaces)
    }
    
    init(target: String, ignoring exclusions: CharacterSet) {
        self.target = target
        self.position = target.unicodeScalars.startIndex
        self.exclusions = exclusions
    }
    
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        
        guard position < target.unicodeScalars.endIndex else {
            // we've matched all of the target
            return false
        }
        
        let targetScalar = target.unicodeScalars[position]
        
        switch (scalar, targetScalar) {
        case (_, _)
                where scalar == targetScalar,
             (CharacterSet.lowercaseLetters, CharacterSet.uppercaseLetters)
                where scalar.value - targetScalar.value == 32,
             (CharacterSet.uppercaseLetters, CharacterSet.lowercaseLetters)
                where targetScalar.value - scalar.value == 32:
            // scalar and target scalar are either an exact match,
            // or equivilant upper/lowercase pair
            // advance the position and return true
            position = target.unicodeScalars.index(after: position)
            return true
        
        case (exclusions, _)
            where position > target.unicodeScalars.startIndex:
            // if:
            // - we've matched at least one of the target scalars; and
            // - this scalar matches a scalar that's can be ignored
            // then:
            // - return true without advancing the position
            return true
            
        default:
            // scalar isn't the next target scalar, or a scalar that can be ignored
            return false
        }
    }
    
    var isComplete: Bool {
        return position == target.unicodeScalars.endIndex
    }
    
    func prepareForReuse() {
        position = target.unicodeScalars.startIndex
    }
}

class DateToken: TokenType {
    
    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?
    
    // public property
    var date: Date {
        return _date!
    }
    
    // formatters are expensive, so only instantiate once for all DateTokens
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()
    
    // called when we access `DateToken.tokenizer`
    required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }
    
    func canTake(_ scalar: UnicodeScalar) -> Bool {
        
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

    var isComplete: Bool {
        if _position == _template.unicodeScalars.endIndex,
            let date = DateToken.dateFormatter.date(from: _dateText) {
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
    
    // return an instance of tokenizer to return in matching tokens
    // we return a copy so that the instance keeps reference to the 
    // dateText that has been matched, and the date that was parsed
    var tokenizerForMatch: TokenType {
        return DateToken(text: _dateText, date: _date)
    }
    
    // only used by `tokenizerForMatch`
    private init(text: String, date: Date?) {
        _dateText = text
        _date = date
        _position = text.unicodeScalars.startIndex
    }
}

class FuzzyMatchTokenTests: XCTestCase {
    
    func testSpecialFormat() {
        
        let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/02/27 (Arrived) ref: 99/99/99"
        let fuzzyTokenzier = FuzzyLiteralMatch(target: "#YF1942B",
                                               ignoring: CharacterSet.whitespaces.union(.punctuationCharacters))
        
        let tokens = messyInput.tokens(from: fuzzyTokenzier, DateToken.tokenizer)
        
        XCTAssert(tokens.count == 3, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].tokenizer is FuzzyLiteralMatch)
        XCTAssert(tokens[0].text == "#YF 1942-b")
        
        XCTAssert(tokens[1].tokenizer is DateToken)
        XCTAssert(tokens[1].text == "12/01/27")
    }
    
    func testDateMatches() {
        
        let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/02/27 (Arrived) ref: 99/99/99"
        let tokens: [DateToken.Token] = messyInput.tokens()
        
        XCTAssert(tokens.count == 2, "Unexpected number of tokens [\(tokens.count)]")
        
        XCTAssert(tokens[0].text == "12/01/27")
        XCTAssert(tokens[0].tokenizer.date == DateToken.dateFormatter.date(from: tokens[0].text))
        
        XCTAssert(tokens[1].text == "12/02/27")
        XCTAssert(tokens[1].tokenizer.date == DateToken.dateFormatter.date(from: tokens[1].text))
        
    }
}


