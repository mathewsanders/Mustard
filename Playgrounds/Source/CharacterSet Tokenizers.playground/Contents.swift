/**
Note: To use framework in a playground, the playground must be opened in a workspace that has the framework.
 
 If you recieve the error *"Playground execution failed: error: no such module 'Mustard'"* then run Project -> Build (⌘B).
*/

import Foundation
import Mustard


//: ## Example 1
//: Match with just letters.
let str = "Hello, playground 2017"

let words = str.components(matchedWith: .letters)
// words.count -> 2
// words = ["hello", "playground"]


//: ## Example 2
//: Match with decimals digits or letters

let tokens: [CharacterSet.Token] = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)

for token in tokens {
    switch token.tokenizer {
    case CharacterSet.decimalDigits:
        print("- digits:", token.text)
    case CharacterSet.letters:
        print("- letters:", token.text)
    default: break
    }
}

// Pull the decimal tokens out by themselves.

let numberTokens = tokens
    .filter { $0.tokenizer == .decimalDigits }
    .map { $0.text }

numberTokens.count  // -> 3
numberTokens        // -> ["123", "45", "67"]

//: ## Example 3
//: Use a custom tokenizer to get numbers with commas and decimals.
struct NumberTokenizer: TokenizerType {
    let unicodeScalars = Set("0123456789.,".unicodeScalars)
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        return unicodeScalars.contains(scalar)
    }
}

let customNumberTokens = "10,123hello456.789".tokens(matchedWith: NumberTokenizer()).map { $0.text }
customNumberTokens.count // -> 2
customNumberTokens       // -> ["10,123", "456.789"]
