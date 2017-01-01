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
    func tokens<T: TokenType>() -> [(tokenizer: T, text: String, range: Range<String.Index>)] {
        
        return self.tokens(from: T()).flatMap({
            if let tokenType = $0.tokenizer as? T {
                return (tokenizer: tokenType, text: $0.text, range: $0.range)
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
        
        var startIndex = text.unicodeScalars.startIndex
        nextToken: while startIndex < text.unicodeScalars.endIndex {
            
            guard let token = tokenizers.lazy.flatMap({ $0.token(startingWith: text.unicodeScalars[startIndex]) }).first else {
                // the character at this position doesn't meet criteria for any
                // any tokens to start with, advance the start position by one and try again
                startIndex = text.unicodeScalars.index(after: startIndex)
                continue nextToken
            }
            
            var currentIndex = startIndex
            while currentIndex < text.unicodeScalars.endIndex {
                
                let nextIndex = text.unicodeScalars.index(after: currentIndex)
                let nextScalar = nextIndex == text.unicodeScalars.endIndex ? nil : text.unicodeScalars[nextIndex]
                
                if let scalar = nextScalar, token.canTake(scalar) {
                    // token can continue matching so expand one position
                    // expand token one position
                    currentIndex = text.unicodeScalars.index(after: currentIndex)
                }
                else {
                    // this token has matched as many scalars as it can
                    
                    if token.isComplete, token.isValid(whenNextScalarIs: nextScalar),
                        
                        let start = startIndex.samePosition(in: text),
                        let next = nextIndex.samePosition(in: text) {
                        // the token could be completed, so will add to matches
                        
                        matches.append(
                            (tokenizer: token.tokenizerForMatch,
                             text: text[start..<next],
                             range: start..<next)
                        )
                    }
                    else {
                        // token could not be completed
                        print("-- token can't complete")
                    }
                    
                    // advance the start index to the next index, 
                    // and break out of the inner loop to grab a 
                    // new token with the scalar at this index
                    token.prepareForReuse()
                    startIndex = nextIndex
                    continue nextToken
                }
            }
        }
        
        return matches
    }
}
