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
        
        var tokenStartIndex = text.unicodeScalars.startIndex
        advanceTokenStart: while tokenStartIndex < text.unicodeScalars.endIndex {
            
            // prepare a backlog of tokens that can start with the current scalar
            let possibleTokens = tokenizers.flatMap({ tokenizer -> TokenType? in
                tokenizer.prepareForReuse()
                return tokenizer.token(startingWith: text.unicodeScalars[tokenStartIndex])
            })
            
            var tokenIndex = possibleTokens.startIndex
            attemptToken: while tokenIndex < possibleTokens.endIndex {
                
                // get a token from the backlog of potential tokens
                let token = possibleTokens[tokenIndex]
                
                var tokenEndIndex = tokenStartIndex
                while tokenEndIndex < text.unicodeScalars.endIndex {
                    
                    // get the scalar at the next position (or nil if we're at the end of the text) 
                    let currentIndex = text.unicodeScalars.index(after: tokenEndIndex)
                    let scalar = (currentIndex == text.unicodeScalars.endIndex) ? nil : text.unicodeScalars[currentIndex]
                    
                    if let scalar = scalar, token.canTake(scalar) {
                        // the scalar is not nil, and the token can take the scalar:
                        // - expand tokenEndIndex one position
                        tokenEndIndex = text.unicodeScalars.index(after: tokenEndIndex)
                    }
                    else if token.isComplete, token.isValid(whenNextScalarIs: scalar),
                        let start = tokenStartIndex.samePosition(in: text),
                        let next = currentIndex.samePosition(in: text) {
                        // the scalar is either nil, or the token can not take it; and
                        // the token is complete, and is valid with context of next scalar/nil:
                        // - append tokenzier, text, and range to matches;
                        // - advance tokenStartIndex to the currentIndex; and
                        // - continue looking for tokens at new startIndex
                        
                        matches.append(
                            (tokenizer: token.tokenizerForMatch,
                             text: text[start..<next],
                             range: start..<next))
                        
                        tokenStartIndex = currentIndex
                        continue advanceTokenStart
                    }
                    else {
                        // the token was not complete, or was invalid given the next scalar:
                        // - tokenStartIndex remains unchanged
                        // - advance the token index
                        // - attempt to match with next token
                        tokenIndex = possibleTokens.index(after: tokenIndex)
                        continue attemptToken
                    }
                }
            }
            
            // token has reached the end of the text
            // advance the tokenStartIndex to attempt match at next scalar
            tokenStartIndex = text.unicodeScalars.index(after: tokenStartIndex)
        }
        
        return matches
    }
}
