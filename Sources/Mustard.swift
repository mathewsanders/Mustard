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

import Swift

public extension String {
    
  
    /// Returns an array of `Token` in the `String` matched using one or more tokenizers of 
    /// type `TokenizerType`.
    ///
    /// - Parameter tokenizers: One or more tokenizers to use to match substrings in the `String`.
    ///
    /// Note: Tokenizers are greedy and are used in the order that they occur within `tokenizers`.
    ///
    /// Typical behavior when using tokeninzers that may match substrings in different ways is
    /// to call this method with the most specific tokenziers before more general tokenizers.
    /// 
    /// If a specifc tokenzier fails to complete a match, subsequent tokenizers will be given the 
    /// opportunity to match a substring.
    ///
    /// Returns: An array of `Token` where each token is a tuple containing a substring from the 
    /// `String`, the range of the substring in the `String`, and an instance of `TokenizerType` 
    /// that matched the substring.
    
    /*
    func tokens<P, C>(matchedWith tokenizer: P) -> [C] where P: TokenizerType, C: TokenType, P.Token == C {
        let results = _tokens(from: [tokenizer.anyTokenizer])
        return results.flatMap({ $0 as? C })
    }
    
    func tokens<P>(matchedWith tokenizer: P) -> [TokenType] where P: TokenizerType {
        return _tokens(from: [tokenizer.anyTokenizer])
    }
    
    func tokens<P, C>(matchedWith tokenizers: [P]) -> [C] where P: TokenizerType, C: TokenType, P.Token == C {
        return _tokens(from: tokenizers.map({ $0.anyTokenizer })).flatMap({ $0 as? C })
    }*/
    
    func tokens(matchedWith tokenizers: AnyTokenizer...) -> [TokenType] {
        return _tokens(from: tokenizers)
    }
    
    internal func _tokens(from tokenizers: [AnyTokenizer]) -> [TokenType]  {
        
        guard !tokenizers.isEmpty else { return [] }
        
        let text = self
        var tokens: [TokenType] = []
        
        var tokenStartIndex = text.unicodeScalars.startIndex
        advanceTokenStart: while tokenStartIndex < text.unicodeScalars.endIndex {
            
            // prepare a backlog of tokens that can start with the current scalar
            let possibleTokenizerss = tokenizers.flatMap({ tokenizer -> AnyTokenizer? in
                tokenizer.prepareForReuse()
                return tokenizer.tokenizerStartingWith(text.unicodeScalars[tokenStartIndex])
            })
            
            var tokenizerIndex = possibleTokenizerss.startIndex
            attemptToken: while tokenizerIndex < possibleTokenizerss.endIndex {
                
                // get a token from the backlog of potential tokens
                let tokenizer = possibleTokenizerss[tokenizerIndex]
                
                var tokenEndIndex = tokenStartIndex
                while tokenEndIndex < text.unicodeScalars.endIndex {
                    
                    // get the scalar at the next position (or nil if we're at the end of the text) 
                    let currentIndex = text.unicodeScalars.index(after: tokenEndIndex)
                    let scalar = (currentIndex == text.unicodeScalars.endIndex) ? nil : text.unicodeScalars[currentIndex]
                    
                    if let scalar = scalar, tokenizer.tokenCanTake(scalar) {
                        // the scalar is not nil, and the token can take the scalar:
                        // - expand tokenEndIndex one position
                        tokenEndIndex = text.unicodeScalars.index(after: tokenEndIndex)
                    }
                    else if tokenizer.tokenIsComplete(), tokenizer.tokenIsValid(whenNextScalarIs: scalar),
                        let start = tokenStartIndex.samePosition(in: text),
                        let next = currentIndex.samePosition(in: text) {
                        // the scalar is either nil, or the token can not take it; and
                        // the token is complete, and is valid with context of next scalar/nil:
                        // - append tokenzier, text, and range to matches;
                        // - advance tokenStartIndex to the currentIndex; and
                        // - continue looking for tokens at new startIndex
                        
                        tokens.append(tokenizer.makeToken(text: text[start..<next], range: start..<next))
                            
                        tokenStartIndex = currentIndex
                        continue advanceTokenStart
                    }
                    else {
                        // the token was not complete, or was invalid given the next scalar:
                        // - tokenStartIndex remains unchanged
                        // - advance the token index
                        // - attempt to match with next token
                        tokenizerIndex = possibleTokenizerss.index(after: tokenizerIndex)
                        continue attemptToken
                    }
                }
            }
            
            // token has reached the end of the text
            // advance the tokenStartIndex to attempt match at next scalar
            tokenStartIndex = text.unicodeScalars.index(after: tokenStartIndex)
        }
        
        return tokens
    }
}
