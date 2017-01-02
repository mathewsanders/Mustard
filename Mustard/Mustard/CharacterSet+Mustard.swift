// CharacterSet+Mustard.swift
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

extension CharacterSet: TokenType {
    public func canTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

extension String {

    /// Returns matches from the string found using tokenizers made from one or more CharacterSet.
    ///
    /// - Parameter characterSets: One or more character sets to match substrings in the string.
    ///
    /// This method is an alias for calling `matches(from tokenizers: TokenType...) -> [Match]`.
    ///
    /// Returns: An array of type `Match` which is a tuple containing an instance of the tokenizer
    /// that matched the result, the substring that was matched, and the range of the matched
    /// substring in this string.
    public func matches(from characterSets: CharacterSet...) -> [Match] {
        return matches(from: characterSets)
    }
}

infix operator ~=
public func ~= (option: CharacterSet, input: TokenType) -> Bool {
    if let characterSet = input as? CharacterSet {
        return characterSet == option
    }
    return false
}
