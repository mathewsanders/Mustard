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

import Foundation

/// Token is a typelias for a tuple with the following named elements:
/// 
/// - tokenizer: An instance of `TokenizerType` that matched the token.
/// - text: A substring that the tokenizer matched in the original string.
/// - range: The range of the matched text in the original string.
public typealias Token = (tokenizer: TokenizerType, text: String, range: Range<String.Index>)

public protocol TokenizerType {
    
    /// Returns an instance of a tokenizer that starts with the given scalar,
    /// or `nil` if this type can't start with this scalar.
    ///
    /// The default implementation of this method returns `self` if `tokenCanStart(with:)` returns true;
    /// otherwise, nil.
    func token(startingWith scalar: UnicodeScalar) -> TokenizerType?
    
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
    var tokenIsComplete: Bool { get }
    
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
    
    /// Initialize an empty instance of the tokenizer.
    init()
    
    /// Returns an instance of the tokenizer that will be used as the `tokenizer` element in the `Token` tuple.
    ///
    /// If the tokenizer implements `NSCopying` protocol, the default implementation returns the result of
    /// `copy(with: nil)`; otherwise, returns `self` which is suitable for structs.
    /// 
    /// Provide an alternate implementation if the tokenizer is a reference type that does not implement `NSCopying`.
    var tokenizerForMatch: TokenizerType { get }
}

public extension TokenizerType {
    
    /// Token is a typelias for a tuple with the following named elements:
    ///
    /// - tokenizer: An instance of `Self` that matched the token.
    /// - text: A substring that the tokenizer matched in the original string.
    /// - range: The range of the matched text in the original string.
    typealias Token = (tokenizer: Self, text: String, range: Range<String.Index>)
    
    /// The default tokenzier for this type.
    /// This is equivilent to using the default initalizer `init()`.
    static var defaultTokenzier: TokenizerType { return Self() }
    
    func tokenCanStart(with scalar: UnicodeScalar) -> Bool {
        return tokenCanTake(scalar)
    }

    /// Returns a boolean value if the token is complete.
    /// This default implementation returns `true`.
    var tokenIsComplete: Bool {
        return true
    }
    
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return false
    }
    
    internal func tokenIsValid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return !completeTokenIsInvalid(whenNextScalarIs: scalar)
    }
    
    func token(startingWith scalar: UnicodeScalar) -> TokenizerType? {
        return tokenCanStart(with: scalar) ? self : nil
    }
    
    func prepareForReuse() {}
    
    /// Returns an instance of the tokenizer that will be used as the `tokenizer` element in the `Token` tuple.
    ///
    /// If the tokenizer implements `NSCopying` protocol, the default implementation returns the result of
    /// `copy(with: nil)`; otherwise, returns `self` which is suitable for structs.
    ///
    /// Provide an alternate implementation if the tokenizer is a reference type that does not implement `NSCopying`.
    var tokenizerForMatch: TokenizerType {
        if let copying = self as? NSCopying, let aCopy = copying.copy(with: nil) as? TokenizerType {
            return aCopy
        }
        else {
            return self
        }
    }
}
