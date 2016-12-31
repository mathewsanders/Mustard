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
    
    // return if this scalar can be included as part of this token
    func canInclude(scalar: UnicodeScalar) -> Bool
    
    // return nil if there are no specific requirements for starting the token
    // otherwise return if this scalar is a valid start for this type of token
    func isRequiredToStart(with scalar: UnicodeScalar) -> Bool?
    
    // if this type of token can be started with this scalar, return a token to use
    // otherwise return nil
    func tokenType(withStartingScalar scalar: UnicodeScalar) -> TokenType?
    
    // TokenType must be able to be created with this initializer
    init()
}

public extension TokenType {
    
    static var tokenizer: TokenType { return Self() }
    
    func isRequiredToStart(with scalar: UnicodeScalar) -> Bool? {
        return nil
    }
    
    func tokenType(withStartingScalar scalar: UnicodeScalar) -> TokenType? {
        if let result = isRequiredToStart(with: scalar) {
            return result ? self : nil
        }
        else if canInclude(scalar: scalar) {
            return self
        }
        else {
            return nil
        }
    }
}
