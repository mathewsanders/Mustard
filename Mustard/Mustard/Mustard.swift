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
                let nextScalar = text.unicodeScalars[nextIndex]
                
                if !token.canAppend(next: nextScalar) {
                    // this token has matched as many scalars as it can
                    
                    if token.canCompleteWhenNextScalar(is: nextScalar),
                        let start = startIndex.samePosition(in: text),
                        let next = nextIndex.samePosition(in: text) {
                        // the token could be completed, so will add to matches
                        
                        matches.append(
                            (tokenType: token,
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
                    startIndex = nextIndex
                    continue nextToken
                }
                else {
                    // token can continue matching so expand one position
                    // expand token one position
                    currentIndex = text.unicodeScalars.index(after: currentIndex)
                }
            }
        }
        
        return matches
    }
}
