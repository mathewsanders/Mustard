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

import Swift

extension CharacterSet: TokenizerType, DefaultTokenizerType {
    public func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return self.contains(scalar)
    }
}

extension String {

    /// Returns an array of `Token` in the `String` matched using tokenization based on one or 
    /// more characterSets.
    ///
    /// - Parameter characterSets: One or more character sets to use as tokenziers to match 
    /// substrings in the `String`.
    ///
    /// This method is an alias for calling `tokens(matchedWith tokenizers: TokenizerType...) -> [Token]`.
    ///
    /// Returns: An array of `Token` where each token is a tuple containing a substring from the
    /// `String`, the range of the substring in the `String`, and an instance of `TokenizerType`
    /// that matched the substring.
    public func tokens(matchedWith characterSets: CharacterSet...) -> [Token] {
        return tokens(from: characterSets)
    }
    
    /// Returns an array containing substrings from the `String` that have been matched by 
    /// tokenization using one or more character sets.
    public func components(matchedWith characterSets: CharacterSet...) -> [String] {
        return tokens(from: characterSets).map({ $0.text })
    }
}

infix operator ~=
public func ~= (option: CharacterSet, input: TokenizerType) -> Bool {
    if let characterSet = input as? CharacterSet {
        return characterSet == option
    }
    return false
}
