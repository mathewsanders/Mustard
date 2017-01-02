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
        nextCharacter: while startIndex < text.unicodeScalars.endIndex {
            
            let validTokenizers = tokenizers.flatMap({ tokenizer -> TokenType? in
                tokenizer.prepareForReuse()
                return tokenizer.token(startingWith: text.unicodeScalars[startIndex])
            })
            
            var tokenizerIndex = validTokenizers.startIndex
            nextTokenizer: while tokenizerIndex < validTokenizers.endIndex {
                
                let token = validTokenizers[tokenizerIndex]
                
                var currentIndex = startIndex
                while currentIndex < text.unicodeScalars.endIndex {
                    
                    let nextIndex = text.unicodeScalars.index(after: currentIndex)
                    let nextScalar = nextIndex == text.unicodeScalars.endIndex ? nil : text.unicodeScalars[nextIndex]
                    
                    if let scalar = nextScalar, token.canTake(scalar) {
                        // token can continue matching so:
                        // - expand token one position
                        currentIndex = text.unicodeScalars.index(after: currentIndex)
                    }
                    else if token.isComplete, token.isValid(whenNextScalarIs: nextScalar),
                        let start = startIndex.samePosition(in: text),
                        let next = nextIndex.samePosition(in: text) {
                        // the token is valid to be added to matches so:
                        // - jump start index forward to next index; and
                        // - start nextCharacter loop with updated start index
                        
                        matches.append(
                            (tokenizer: token.tokenizerForMatch,
                             text: text[start..<next],
                             range: start..<next))
                        
                        startIndex = nextIndex
                        continue nextCharacter
                    }
                    else {
                        // token could not be added to matches so:
                        // - advance the tokenizer index by one place
                        // - start nextTokenizer loop with updated tokenizer index
                        tokenizerIndex = validTokenizers.index(after: tokenizerIndex)
                        continue nextTokenizer
                    }
                }
            }
            
            // the character at this position doesn't meet criteria for any
            // any tokens to start with, advance the start position by one and try again
            startIndex = text.unicodeScalars.index(after: startIndex)
        }
        
        return matches
    }
}
