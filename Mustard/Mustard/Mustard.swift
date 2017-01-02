// Mustard.swift
//
// Copyright (c) 2017 Mathew Sanders
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

public extension String {
    
    /// Returns matches from the string found using a single tokenizer of type `TokenType`.
    /// 
    /// The type of TokenType that is used is inferred by the result type.
    ///
    /// ~~~~
    /// // example usage:
    /// // `WordToken` is a `TokenType` that matches any letter characters.
    /// let input = "ab cd ef"
    /// let matches: [WordToken.Match] = input.matches()
    /// // matches.count -> 3
    /// //
    /// // matches[0] -> 
    /// // (tokenizer: WordToken(), 
    /// //  text: "ab", 
    /// //  range: Range<String.Index>(0, 2))
    /// ~~~~
    ///
    /// Note: Using this method initalizes the TokenType with the default initalizer `init()`.
    /// If the tokenizer needs to use another initalizer, then use the `matches(from:)` method
    /// to find matches instead.
    ///
    /// Returns: An array of type `T.Match` where T is the generic `TokenType` used.
    func matches<T: TokenType>() -> [(tokenizer: T, text: String, range: Range<String.Index>)] {
        
        return self.matches(from: T()).flatMap({
            if let tokenType = $0.tokenizer as? T {
                return (tokenizer: tokenType, text: $0.text, range: $0.range)
            }
            else { return nil }
        })
    }
    
    /// Returns matches from the string found using one or more tokenizers of type `TokenType`.
    /// 
    /// - Parameter tokenizers: One or more tokenizers to use to match substrings in the string.
    ///
    /// Tokenizers are greedy and are used in the order that they occur within `tokenizers`.
    ///
    /// Typical behavior when using tokeninzers that may match substrings in different ways is
    /// to call this method with the most specific tokenziers before more general tokenizers.
    /// 
    /// If a specifc tokenzier fails to complete a match, the general tokenizer still has a 
    /// chance to match it later.
    ///
    /// Returns: An array of type `Match` which is a tuple containing an instance of the tokenizer
    /// that matched the result, the substring that was matched, and the range of the matched 
    /// substring in this string.
    func matches(from tokenizers: TokenType...) -> [Match] {
        return matches(from: tokenizers)
    }
    
    internal func matches(from tokenizers: [TokenType]) -> [Match] {
        
        guard !tokenizers.isEmpty else { return [] }
        
        let text = self
        var matches: [Match] = []
        
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
