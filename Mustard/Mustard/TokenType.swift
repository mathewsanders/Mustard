//
//  TokenType.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/31/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import Foundation

public typealias Token = (tokenType: TokenType, text: String, range: Range<String.Index>)

public protocol TokenType {
    
    // check if token can start with a scalar
    func canStart(with scalar: UnicodeScalar) -> Bool
    
    // check if token can append next scalar
    func canAppend(next scalar: UnicodeScalar) -> Bool
    
    // check if token can be completed based on next character
    func canCompleteWhenNextScalar(is scalar: UnicodeScalar) -> Bool
    
    // if this type of token can be started with this scalar, return a token to use
    // otherwise return nil
    func token(startingWith scalar: UnicodeScalar) -> TokenType?
    
    // TokenType must be able to be created with this initializer
    init()
}

public extension TokenType {
    
    static var tokenizer: TokenType { return Self() }
    
    func canStart(with scalar: UnicodeScalar) -> Bool {
        return canAppend(next: scalar)
    }
    
    func canCompleteWhenNextScalar(is scalar: UnicodeScalar) -> Bool {
        return true
    }
    
    func token(startingWith scalar: UnicodeScalar) -> TokenType? {
        return canStart(with: scalar) ? self : nil
    }
}
