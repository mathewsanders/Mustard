//
//  TokenType.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import Foundation

/// A tuple capturing information about a token match.
/// 
/// - tokenType: The instance of `TokenType` that matched the token.
/// - text: The text that the token matched.
/// - range: The range of the matched text in the original input.
public typealias Token = (tokenizer: TokenType, text: String, range: Range<String.Index>)

public protocol TokenType {
    
    /// Asks the token if it can start with the given scalar.
    ///
    /// The default implementation of this method is an alias for `canTake(_:)`.
    /// Implement this method if the token has unique criteria for the first scalar to match.
    ///
    /// - Parameter scalar: The scalar to check.
    /// 
    /// - Returns: `true` if the token can start with this scalar; otherwise, false.
    func canStart(with scalar: UnicodeScalar) -> Bool
    
    /// Asks the token if if can capture this scalar as a valid match.
    ///
    /// - Parameter scalar: The scalar to check using the token.
    ///
    /// - Returns: `true` if the token can take this this scalar; otherwise, false.
    func canTake(_ scalar: UnicodeScalar) -> Bool

    /// Returns a boolean value if the token is complete.
    var isComplete: Bool { get }
    
    /// Asks the token if it is invalid given context of the first scalar following this token.
    ///
    /// The default implementation of this method performs always returns `false`.
    /// Implement this method to return `true` in situations where a token can not be followed
    /// by certain scalars.
    ///
    /// - Parameter scalar: The first scalar following this token, or `nil` if the token has
    /// reached the end of the text.
    ///
    /// - Returns: `true` if the token is invalid with the following scalar; otherwise, false.
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool
    
    /// Ask the token to prepare itself to start matching a new series of scalars.
    ///
    /// The default implementation of this method does nothing.
    /// Implement this method to reset the token if calls to `canTake(_:)` change the state 
    /// of the token.
    func prepareForReuse()
    
    /// Returns an instance of that can start with the given scalar,
    /// or `nil` if type can't start with this scalar.
    /// 
    /// The default implementation of this method returns itself if `canStart(with:)` returns true;
    /// otherwise, nil.
    func token(startingWith scalar: UnicodeScalar) -> TokenType?
    
    /// Initialize an empty instance.
    init()
    
    /// Returns a new instance of a token that's a copy of the reciever.
    ///
    /// The object returned is set as the `tokenizer` element from a call to `tokens()`
    /// If the type implements NSCopying protocol, the default implementation returns the result of
    /// `copy(with: nil)`; otherwise, returns self.
    var tokenizerForMatch: TokenType { get }
    
}

public extension TokenType {
    
    typealias Token = (tokenizer: Self, text: String, range: Range<String.Index>)
    
    static var tokenizer: TokenType { return Self() }
    
    func canStart(with scalar: UnicodeScalar) -> Bool {
        return canTake(scalar)
    }

    var isComplete: Bool {
        return true
    }
    
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return false
    }
    
    internal func isValid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        return !completeTokenIsInvalid(whenNextScalarIs: scalar)
    }
    
    func token(startingWith scalar: UnicodeScalar) -> TokenType? {
        return canStart(with: scalar) ? self : nil
    }
    
    func prepareForReuse() {}
    
    var tokenizerForMatch: TokenType {
        if let copying = self as? NSCopying, let aCopy = copying.copy(with: nil) as? TokenType {
            return aCopy
        }
        else {
            return self
        }
    }
}
