//
//  CharacterSet+Mustard.swift
//  Mustard
//
//  Created by Mathew Sanders on 12/30/16.
//  Copyright © 2016 Mathew Sanders. All rights reserved.
//

import Foundation

extension CharacterSet: TokenType {
    public func canAppend(next scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

extension String {
    public func tokens(from characterSets: CharacterSet...) -> [Token] {
        return tokens(from: characterSets)
    }
}

infix operator ~=
public func ~= (option: CharacterSet, input: TokenType) -> Bool {
    if let characterSet = input as? CharacterSet {
        return characterSet == option
    }
    return false
}
