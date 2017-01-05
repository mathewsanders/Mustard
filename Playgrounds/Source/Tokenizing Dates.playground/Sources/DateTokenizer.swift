//
//  DateTokenizer.swift
//  
//
//  Created by Mathew Sanders on 1/2/17.
//
//

import Swift
import Mustard

infix operator ~=
func ~= (option: CharacterSet, input: UnicodeScalar) -> Bool {
    return option.contains(input)
}

public class DateTokenizer: TokenizerType, DefaultTokenizerType {
    
    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?
    
    // formatters are expensive, so only instantiate once for all DateTokens
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()
    
    // called when we access `DateToken.tokenizer`
    public required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }
    
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        
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
    
    public func tokenIsComplete() -> Bool {
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
    public func prepareForReuse() {
        _dateText = ""
        _date = nil
        _position = _template.unicodeScalars.startIndex
    }
    
    // return an instance of tokenizer to return in matching tokens
    // we return a copy so that the instance keeps reference to the
    // dateText that has been matched, and the date that was parsed

    public struct DateToken: TokenType {
        public let text: String
        public let range: Range<String.Index>
        public let date: Date
    }
    
    public func makeToken(text: String, range: Range<String.Index>) -> DateToken {
        print("making date token, _date is", _date)
        return DateToken(text: text, range: range, date: _date ?? Date())
    }
    
}
