//
//  PerformanceTests.swift
//  Mustard
//
//  Created by Mat on 1/4/17.
//  Copyright © 2017 Mathew Sanders. All rights reserved.
//

import XCTest
import Mustard

class PerformanceTests: XCTestCase {
    
    let iterations = 10000
    
    let sampleWordsWithSeparatingSpaces = "Sing a song of sixpence, A pocket full of rye. four and twenty blackbirds, Baked in a pie. When the pie was opened The birds began to sing; Wasn't th "
    
    // Sing a song of sixpence, A pocket full of rye. four and twenty blackbirds, Baked in a pie. When the pie was opened The birds began to sing; Wasn't that a dainty dish, To set before the king The king was in his counting house, Counting out his money; The queen was in the parlour, Eating bread and honey. The maid was in the garden, Hanging out the clothes, When down came a blackbird And pecked off her nose.
    
    func testPerformance_Words_ComponentsSeparatedByCharacterSet() {
        
        let separatingCharacters = CharacterSet.whitespaces
        
        let check = self.sampleWordsWithSeparatingSpaces.components(separatedBy: separatingCharacters)
        XCTAssert(check.count == 31, "unexpected number of components \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleWordsWithSeparatingSpaces.components(separatedBy: separatingCharacters)
            }
        }
    }
    
    func testPerformance_Words_ComponentsSeparatedByString() {
        
        let separatingCharacters = " "
        
        let check = self.sampleWordsWithSeparatingSpaces.components(separatedBy: separatingCharacters)
        XCTAssert(check.count == 31, "unexpected number of components \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleWordsWithSeparatingSpaces.components(separatedBy: separatingCharacters)
            }
        }
    }
    
    func testPerformance_Words_MustardMatchedWithLetters() {
        
        let matchingCharacters = CharacterSet.letters
        
        let check = self.sampleWordsWithSeparatingSpaces.components(matchedWith: matchingCharacters)
        
        // "Wasn't" matched as two components
        XCTAssert(check.count == 31, "unexpected number of components \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleWordsWithSeparatingSpaces.components(matchedWith: matchingCharacters)
            }
        }
    }
    
    func _wordsWithScannerScanningLetters(from text: String) -> [String] {
        let matchingCharacters = CharacterSet.letters
        
        var results: [String] = []
        let scanner = Scanner(string: text)
        
        while !scanner.isAtEnd {
            if let word = scanner.scanCharacters(from: matchingCharacters){
                results.append(word)
            }
            else {
                scanner.scanLocation += 1
            }
        }
        return results
    }
    
    func testPerformance_Words_ScannerIgnoreWhitespace() {
        
        let check = _wordsWithScannerScanningLetters(from: sampleWordsWithSeparatingSpaces)
        
        // "Wasn't" matched as two components
        XCTAssert(check.count == 31, "unexpected number of components \(check.count)")

        self.measure {
            for _ in 0..<self.iterations {
                _ = self._wordsWithScannerScanningLetters(from: self.sampleWordsWithSeparatingSpaces)
            }
        }
    }
    
    func _wordsWithScannerWhitespaceBoundary(from text: String) -> [String] {
        let separatingCharacters = CharacterSet.whitespaces
        
        var results: [String] = []
        let scanner = Scanner(string: text)
        scanner.charactersToBeSkipped = nil
        
        while !scanner.isAtEnd {
            if let word = scanner.scanUpToCharacters(from: separatingCharacters){
                results.append(word)
            }
            else {
                scanner.scanLocation += 1
            }
        }
        return results
    }
    
    func testPerformance_Words_ScannerUptoWhitespace() {
        
        let check = _wordsWithScannerWhitespaceBoundary(from: sampleWordsWithSeparatingSpaces)
        XCTAssert(check.count == 30, "unexpected number of components \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self._wordsWithScannerWhitespaceBoundary(from: self.sampleWordsWithSeparatingSpaces)
            }
        }
    }
    
    func _wordsUsingRegularExpression(from text: String) -> [String] {
        
        let pattern = "\\w+"
        let formatter = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let matches = formatter.matches(in: text, options: [], range: text.nsrange)
        
        return matches.map { match in
            text.substring(with: match.rangeAt(0))!
        }
    }
    
    func testPerformance_Words_RegularExpression() {
        
        let check = _wordsUsingRegularExpression(from: sampleWordsWithSeparatingSpaces)
        XCTAssert(check.count == 31, "unexpected number of components \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self._wordsUsingRegularExpression(from: self.sampleWordsWithSeparatingSpaces)
            }
        }
    }
    
    let sampleWordsAndNumbers = "zero0one1two2three3four4five5six6seven7eight8nine9ten10eleven11twelve12thirteen13fourteen14fifteen15sixteen16seventeeen17eigthteen18nineteen19twenty20"
    
    func testPerformance_NumbersAndWords_Mustard() {
        
        let check = self.sampleWordsAndNumbers.components(matchedWith: CharacterSet.letters, CharacterSet.decimalDigits)
        
        // "Wasn't" matched as two components
        XCTAssert(check.count == 42, "unexpected number of matches \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleWordsAndNumbers.components(matchedWith: CharacterSet.letters, CharacterSet.decimalDigits)
            }
        }
    }
    
    func _numbersAndWordsWithScanner(from text: String) -> [String] {
        
        var results: [String] = []
        let scanner = Scanner(string: text)
        
        while !scanner.isAtEnd {
            if let word = scanner.scanCharacters(from: .letters){
                results.append(word)
            }
            else if let number = scanner.scanInt() {
                results.append("\(number)")
            }
            else {
                scanner.scanLocation += 1
            }
        }
        return results
    }
    
    func testPerformance_NumbersAndWords_Scanner() {
        
        let check = _numbersAndWordsWithScanner(from: sampleWordsAndNumbers)
        
        XCTAssert(check.count == 42, "unexpected number of matches \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self._numbersAndWordsWithScanner(from: self.sampleWordsAndNumbers)
            }
        }
    }
    
    func _numbersAndWordsUsingRegularExpression(from text: String) -> [String] {
        
        let pattern = "\\d+|[a-zA-Z]+" // match one or more digit or one or more ascii letters
        let formatter = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let matches = formatter.matches(in: text, options: [], range: text.nsrange)
        
        return matches.map { match in
            text.substring(with: match.rangeAt(0))!
        }
    }
    
    func testPerformance_NumbersAndWords_RegularExpression() {
        
        let check = _numbersAndWordsUsingRegularExpression(from: sampleWordsAndNumbers)
        XCTAssert(check.count == 42, "unexpected number of matches \(check.count)")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self._numbersAndWordsUsingRegularExpression(from: self.sampleWordsAndNumbers)
            }
        }
    }
    
    //
    
    let sampleDates = "Ref 01/55/99 Check in at 03/29/17, departure at 04/12/17, you have dinner reservations on 04/01/17, lunch on 04/02/17 and a show on night of 04/03/12."
    
    func _datesUsingRegularExpression(from text: String) -> [String] {
        
        let pattern = "[0-9]{2}/[0-9]{2}/[0-9]{2}" // match 00/00/00
        let formatter = try! NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let matches = formatter.matches(in: text, options: [], range: text.nsrange)
        
        return matches.map { match in
            text.substring(with: match.rangeAt(0))!
        }
    }
    
    func testPerformance_Dates_RegularExpression() {
        
        let check = _datesUsingRegularExpression(from: sampleDates)
        XCTAssert(check.count == 6, "unexpected number of matches \(check.count)")
        XCTAssert(check[0] == "01/55/99")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self._datesUsingRegularExpression(from: self.sampleDates)
            }
        }
    }
    
    func testPerformance_Dates_Mustard() {
        
        let check = sampleDates.tokens(matchedWith: DateTokenizer())
        XCTAssert(check.count == 5, "unexpected number of matches \(check.count)")
        XCTAssert(check[0].text == "03/29/17")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleDates.tokens(matchedWith: DateTokenizer())
            }
        }
    }
    
    func testPerformance_DatesPattern_Mustard() {
        
        let check = sampleDates.tokens(matchedWith: DatePatternTokenizer())
        XCTAssert(check.count == 6, "unexpected number of matches \(check.count)")
        XCTAssert(check[0].text == "01/55/99")
        
        self.measure {
            for _ in 0..<self.iterations {
                _ = self.sampleDates.tokens(matchedWith: DatePatternTokenizer())
            }
        }
    }
}

final class DatePatternTokenizer: TokenizerType, DefaultTokenizerType {
    
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    
    required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }
    
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
        if _position == _template.unicodeScalars.endIndex {
            // we've reached the end of the template
            
            return true
        }
        else {
            return false
        }
    }
    
    // reset the tokenizer for matching new date
    func prepareForReuse() {
        _dateText = ""
        _position = _template.unicodeScalars.startIndex
    }
    
    struct DateFormatToken: TokenType {
        let text: String
        let range: Range<String.Index>
    }
    
    func makeToken(text: String, range: Range<String.Index>) -> DateFormatToken {
        return DateFormatToken(text: text, range: range)
    }
}

// Scanner extensions
extension Scanner {
    func scanCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanCharacters(from:set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }
    
    func scanUpToCharacters(from set: CharacterSet) -> String? {
        var value: NSString? = ""
        if scanUpToCharacters(from: set, into: &value),
            let value = value as? String {
            return value
        }
        return nil
    }
    
    func scanDouble() -> Double? {
        var value = 0.0
        if scanDouble(&value) {
            return value
        }
        return nil
    }
    
    func scanInt() -> Int32? {
        var value: Int32 = 0
        if scanInt32(&value) {
            return value
        }
        return nil
    }
}

// Extensions to help using regular expressions via http://nshipster.com/nsregularexpression/
extension String {
    /// An `NSRange` that represents the full range of the string.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }
    
    /// Returns a substring with the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func substring(with nsrange: NSRange) -> String? {
        guard let range = nsrange.toRange()
            else { return nil }
        let start = UTF16Index(range.lowerBound)
        let end = UTF16Index(range.upperBound)
        return String(utf16[start..<end])
    }
    
    /// Returns a range equivalent to the given `NSRange`,
    /// or `nil` if the range can't be converted.
    func range(from nsrange: NSRange) -> Range<Index>? {
        guard let range = nsrange.toRange() else { return nil }
        let utf16Start = UTF16Index(range.lowerBound)
        let utf16End = UTF16Index(range.upperBound)
        
        guard let start = Index(utf16Start, within: self),
            let end = Index(utf16End, within: self)
            else { return nil }
        
        return start..<end
    }
}
