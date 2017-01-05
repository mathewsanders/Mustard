// TokenizerType.swift
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

public protocol TokenType {
    var text: String { get }
    var range: Range<String.Index> { get }
}

public struct AnyToken: TokenType {
    public let text: String
    public let range: Range<String.Index>
    public let type: Any
}

/// Defines the implementation needed to create a tokenizer for use with Mustard.
public protocol TokenizerType {
    
    associatedtype Token: TokenType
    
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
