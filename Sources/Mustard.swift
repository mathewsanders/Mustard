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
import Swift

/// Defines requirements for a token
public protocol TokenType {
    /// The text matched
    var text: String { get }
    
    /// The range of the text in the original string
    var range: Range<String.Index> { get }
}

public struct AnyToken: TokenType {
    public let text: String
    public let range: Range<String.Index>
    
    /// The type of tokenzier that matched this token.
    public let type: Any
}

/// Defines the implementation needed to create a tokenizer for use with Mustard.
public protocol TokenizerType {
    
    /// The type of token associated with this tokenizer, the default implementation uses 
    /// `AnyToken` as a fallback if no specific type is defined.
    associatedtype Token: TokenType
    
    /// Returns a token to be included in matching results.
    /// The default implementation returns an instance of `AnyToken` which includes the text matched, 
    /// the range of the text in the original string, and the type of tokenizer that matched the text.
    ///
    /// Provide an alternate implementation if you have additional information that you want to expose 
    /// through the token.
    func makeToken(text: String, range: Range<String.Index>) -> Token
    
    /// Returns an instance of a tokenizer that starts with the given scalar,
    /// or `nil` if this type can't start with this scalar.
    ///
    /// The default implementation of this method returns `self` if `tokenCanStart(with:)` returns true;
    /// otherwise, nil.
    func tokenizerStartingWith(_ scalar: UnicodeScalar) -> AnyTokenizer?
    
    /// Checks if tokens of this type can start with the given scalar.
    ///
    /// The default implementation of this method is an alias for `tokenCanTake(_:)`.
    /// Provide an alternate implementation if tokens have special starting criteria.
    ///
    /// - Parameter scalar: The scalar the token could start with.
    ///
    /// - Returns: `true` if the token can start with this scalar; otherwise, false.
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool
    
    /// Checks if tokens can include this scalar as part of a token.
    ///
    /// This method is called multiple times for each subsequent scalar in a String until the tokenizer
    /// returns `false`.
    ///
    /// - Parameter scalar: The scalar the token could include.
    ///
    /// - Returns: `true` if the token can take this this scalar; otherwise, false.
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool
    
    /// Returns a boolean value if the token is considered complete.
    ///
    /// The default implementation returns `true`.
    ///
    /// Provide an alternate implementation if tokens have some internal criteria that need to be
    /// satisfied before a token is complete.
    func tokenIsComplete() -> Bool
    
    /// Checks if a complete token should be discarded given the context of the first scalar following this token.
    ///
    /// The default implementation of this method performs always returns `false`.
    ///
    /// Provide an alternate implementation to return `true` in situations where a token can not be followed
    /// by certain scalars.
    ///
    /// - Parameter scalar: The first scalar following this token, or `nil` if the tokenizer has
    /// matched a token that reaches the end of the text.
    ///
    /// - Returns: `true` if the token is invalid with the following scalar; otherwise, false.
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool
    
    /// Ask the tokenizer to prepare itself to start matching a new series of scalars.
    ///
    /// The default implementation of this method does nothing.
    ///
    /// Provide an alternate implementation if the tokenizer maintains an internal state that updates based on calls to
    /// `tokenCanTake(_:)`
    func prepareForReuse()
    
}


public struct AnyTokenizer: TokenizerType {
    
    private let _makeToken: (String, Range<String.Index>) -> TokenType
    private let _tokenizerStartingWith: (UnicodeScalar) -> AnyTokenizer?
    private let _tokenCanStart: (UnicodeScalar) -> Bool
    private let _tokenCanTake: (UnicodeScalar) -> Bool
    private let _tokenIsComplete: () -> Bool
    private let _completeTokenIsInvalid: (UnicodeScalar?) -> Bool
    private let _prepareForReuse: () -> ()
    
    init<P>(_ tokenizer: P) where P: TokenizerType {
        _makeToken = tokenizer.makeToken
        _tokenizerStartingWith = tokenizer.tokenizerStartingWith
        _tokenCanStart = tokenizer.tokenCanStart
        _tokenCanTake = tokenizer.tokenCanTake
        _tokenIsComplete = tokenizer.tokenIsComplete
        _completeTokenIsInvalid = tokenizer.completeTokenIsInvalid
        _prepareForReuse = tokenizer.prepareForReuse
    }
    
    public func makeToken(text: String, range: Range<String.Index>) -> TokenType {
        return _makeToken(text, range)
    }
    
    public func tokenizerStartingWith(_ scalar: UnicodeScalar) -> AnyTokenizer? {
        return _tokenizerStartingWith(scalar)
    }
    
    public func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return _tokenCanStart(scalar)
    }
    
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return _tokenCanTake(scalar)
    }
    
    public func tokenIsComplete() -> Bool {
        return _tokenIsComplete()
    }
    
    public func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return _completeTokenIsInvalid(scalar)
    }
    
    public func prepareForReuse() {
        _prepareForReuse()
    }
}

/// Defines the implementation needed for a TokenizerType to have some convenience methods
/// enabled when the tokenizer has a default initializer.
public protocol DefaultTokenizerType: TokenizerType {
    
    /// Initialize an empty instance of the tokenizer.
    init()
}

extension DefaultTokenizerType {
    /// The default tokenzier for this type.
    /// This is equivilent to using the default initalizer `init()`.
    public static var defaultTokenzier: AnyTokenizer { return Self().anyTokenizer }
}

public extension TokenizerType {
    
    var anyTokenizer: AnyTokenizer {
        return AnyTokenizer(self)
    }
    
    func makeToken(text: String, range: Range<String.Index>) -> AnyToken {
        return AnyToken(text: text, range: range, type: type(of: self))
    }
    
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return tokenCanTake(scalar)
    }
    
    /// Returns a boolean value if the token is complete.
    /// This default implementation returns `true`.
    func tokenIsComplete() -> Bool {
        return true
    }
    
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return false
    }
    
    func tokenIsValid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return !completeTokenIsInvalid(whenNextScalarIs: scalar)
    }
    
    func tokenizerStartingWith(_ scalar: UnicodeScalar) -> AnyTokenizer? {
        return tokenCanStart(with: scalar) ? self.anyTokenizer : nil
    }
    
    func prepareForReuse() {}
    
}



public extension String {
    
    
    /// Returns an array of tokens in the `String` matched using one or more tokenizers of
    /// the same type.
    ///
    /// - Parameter tokenizers: One or more tokenizers of the same type to match substrings in the `String`.
    ///
    /// Note: Tokenizers are greedy and are used in the order that they occur within `tokenizers`.
    ///
    /// Typical behavior when using tokeninzers that may match substrings in different ways is
    /// to call this method with the most specific tokenziers before more general tokenizers.
    ///
    /// If a specifc tokenzier fails to complete a match, subsequent tokenizers will be given the
    /// opportunity to match a substring.
    ///
    /// Returns: An array of `Token` where each token is the type `Tokenizer.Token`.
    func tokens<Tokenizer, Token>(matchedWith tokenizers: Tokenizer...) -> [Token] where Tokenizer: TokenizerType, Token: TokenType, Tokenizer.Token == Token {
        let results = _tokens(from: tokenizers.map({ $0.anyTokenizer }))
        return results.flatMap({ $0 as? Token })
    }
    
    /// Returns an array of tokens in the `String` matched using one or more tokenizers of
    /// the same type.
    ///
    /// - Parameter anyTokenizers: One or more tokenizers of any type to match substrings in the `String`.
    ///
    /// Note: Tokenizers are greedy and are used in the order that they occur within `tokenizers`.
    ///
    /// Typical behavior when using tokeninzers that may match substrings in different ways is
    /// to call this method with the most specific tokenziers before more general tokenizers.
    ///
    /// If a specifc tokenzier fails to complete a match, subsequent tokenizers will be given the
    /// opportunity to match a substring.
    ///
    /// Returns: An array of `TokenType`.
    func tokens(matchedWith anyTokenizers: AnyTokenizer...) -> [TokenType] {
        return _tokens(from: anyTokenizers)
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
