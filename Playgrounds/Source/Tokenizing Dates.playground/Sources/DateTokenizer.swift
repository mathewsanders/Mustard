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

final public class DateTokenizer: TokenizerType, DefaultTokenizerType {
    
    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?
    
    // public property
    
    // called when we access `DateToken.defaultTokenizer`
    public required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }
    
    // formatters are expensive, so only instantiate once for all DateTokens
    public static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()
    
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
    
    public struct DateToken: TokenType {
        public let text: String
        public let range: Range<String.Index>
        public let date: Date
    }
    
    public func makeToken(text: String, range: Range<String.Index>) -> DateToken {
        return DateToken(text: text, range: range, date: _date!)
    }
}
