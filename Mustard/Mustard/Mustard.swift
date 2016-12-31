//
//  Mustard.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import Foundation

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
            
            guard let tokenType = tokenizers.lazy.flatMap({ $0.tokenType(withStartingScalar: text.unicodeScalars[startPosition]) }).first else {
                // the character at this position doesn't meet criteria for any
                // any tokens to start with, advance the start position by one and try again
                
                startPosition = text.unicodeScalars.index(after: startPosition)
                continue
            }
            
            var currentPosition = startPosition
            
            while currentPosition <= text.unicodeScalars.endIndex {
                
                let isStart = currentPosition == startPosition
                let currentCharacter = text.unicodeScalars[currentPosition]
                
                if currentPosition < text.unicodeScalars.endIndex &&  // reached the last character
                    tokenType.canInclude(scalar: currentCharacter)    // character can be included
                    || isStart && tokenType.isRequiredToStart(with: currentCharacter) ?? false { // or special start requirement met
                    
                    currentPosition = text.unicodeScalars.index(after: currentPosition)
                }
                else {
                    if let start = startPosition.samePosition(in: text),
                        let end = currentPosition.samePosition(in: text) {
                        
                        matches.append((tokenType: tokenType,
                                        text: text[start..<end],
                                        range: start..<end))
                    }
                    break
                }
            }
            startPosition = currentPosition
        }
        
        return matches
    }
}
