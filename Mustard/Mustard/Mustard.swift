//
//  Mustard.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import Foundation

public typealias Token = (tokenType: TokenType, text: String, range: Range<String.Index>)

public protocol TokenType {
    
    static var tokenizer: TokenType { get }
    
    init()
    
    // return valid characters for this token type
    func tokenCanInclude(scalar: UnicodeScalar) -> Bool
    
    // returns a tokenizer based on first character
    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType?
}

public extension TokenType {
    static var tokenizer: TokenType { return Self() }
}

public extension String {
    
    /// Returns tokens matching a single `TokenType` implied by the generic signature
    func tokens<T: TokenType>() -> [(tokenType: T, text: String, range: Range<String.Index>)] {
        
        return self.tokens(from: T()).flatMap({
            if let tokenType = $0.tokenType as? T {
                return (tokenType: tokenType, text: $0.text, range: $0.range)
            }
            else { return nil }
        })
    }
    
    /// Returns tokens matching tokenizers
    func tokens(from tokenizers: TokenType...) -> [Token] {
        return tokens(from: tokenizers)
    }
    
    internal func tokens(from tokenizers: [TokenType]) -> [Token] {
        
        guard !tokenizers.isEmpty else { return [] }
        
        let text = self
        
        var matches: [Token] = []
        
        var startPosition = text.unicodeScalars.startIndex
        while startPosition < text.unicodeScalars.endIndex {
            
            guard let tokenType = tokenizers.lazy.flatMap({ $0.tokenType(startingWith: text.unicodeScalars[startPosition]) }).first else {
                // the character at this position doesn't meet criteria for any
                // any tokens to start with, advance the start position by one and try again
                
                startPosition = text.unicodeScalars.index(after: startPosition)
                continue
            }
            
            var currentPosition = startPosition
            while currentPosition <= text.unicodeScalars.endIndex {
                // start by setting upper bound to the lower bound position...
                
                //print(text.unicodeScalars[currentPosition])
                
                if currentPosition < text.unicodeScalars.endIndex,
                    tokenType.tokenCanInclude(scalar: text.unicodeScalars[currentPosition]) {
                    // if:
                    // - there is an upcoming character; and
                    // - that next character is a valid character for the current token
                    // then: extend the current position up one position
                    
                    currentPosition = text.unicodeScalars.index(after: currentPosition)
                }
                else {
                    // either:
                    // - there isn't a next characters (end of text), or
                    // - the next character doesn't match the current token search critera
                    
                    if let start = startPosition.samePosition(in: text),
                        let end = currentPosition.samePosition(in: text) {
                        // append token type, text, and range into matches
                        
                        matches.append((tokenType: tokenType,
                                        text: text[start..<end],
                                        range: start..<end))
                    }
                    break
                }
            }
            startPosition = currentPosition // jump start position up to the current position
        }
        
        return matches
    }
}
