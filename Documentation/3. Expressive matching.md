# Example: expressive matching

The results returned by `matches(from:)`returns an array tuples with the signature `(tokenizer: TokenType, text: String, range: Range<String.Index>)`

To make use of the `tokenizer` element, you need to either use type casting (using `as?`) or type checking (using `is`) for the `tokenizer` element to be useful.

Maybe we want to filter out only tokens that are numbers:

````Swift
import Mustard

let messy = "123Hello world&^45.67"
let matches = messy.matches(from: .decimalDigits, .letters)
// matches.count -> 5

let numbers = matches.filter({ $0.tokenizer is NumberToken })
// numbers.count -> 0

````

This can lead to bugs in your logic-- in the example above `numberTokens` will be empty because the tokenizers used were the character sets `.decimalDigits`, and `.letters`, so the filter won't match any of the tokens.

This may seem like an obvious error, but it's the type of unexpected bug that can slip in when we're using loosely typed results.

Thankfully, Mustard can return a strongly typed set of matches if a single `TokenType` is used:

````Swift
import Mustard

let messy = "123Hello world&^45.67"

// call `matches()` method on string to get matching tokens from string
let numberMatches: [NumberToken.Match] = messy.matches()
// numberMatches.count -> 2

````

Used in this way, this isn't very useful, but it does allow for multiple `TokenType` to be bundled together as a single `TokenType` by implementing a TokenType using an `enum`.

An enum token type can either manage it's own internal state, or potentially act as a lightweight wrapper to existing tokenizers.
Here's an example `TokenType` that acts as a wrapper for word, number, and emoji tokenizers:

````Swift

enum MixedToken: TokenType {

    case word
    case number
    case emoji
    case none // 'none' case not strictly needed, and
              // in this implementation will never be matched

    init() {
        self = .none
    }

    static let wordToken = WordToken()
    static let numberToken = NumberToken()
    static let emojiToken = EmojiToken()

    func canAppend(next scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedToken.wordToken.canAppend(next: scalar)
        case .number: return MixedToken.numberToken.canAppend(next: scalar)
        case .emoji: return MixedToken.emojiToken.canAppend(next: scalar)
        case .none:
            return false
        }
    }

    func token(startingWith scalar: UnicodeScalar) -> TokenType? {

        if let _ = MixedToken.wordToken.token(startingWith: scalar) {
            return MixedToken.word
        }
        else if let _ = MixedToken.numberToken.token(startingWith: scalar) {
            return MixedToken.number
        }
        else if let _ = MixedToken.emojiToken.token(startingWith: scalar) {
            return MixedToken.emoji
        }
        else {
            return nil
        }
    }
}
````

Mustard defines a default typealias for `Token` that exposes the specific type in the
results tuple.

````Swift
public extension TokenType {
    typealias Match = (tokenizer: Self, text: String, range: Range<String.Index>)
}
````

Setting your results array to this type gives you the option to use the shorter `matches()` method,
where Mustard uses the inferred type to perform tokenization.

Since the matches array is strongly typed, you can be more expressive with the results, and the
complier can give you more hints to prevent you from making mistakes.

````Swift

// use the `matches()` method to grab matching substrings using a single tokenizer
let matches: [MixedToken.Match] = "123👩‍👩‍👦‍👦Hello world👶 again👶🏿 45.67".matches()
// matches.count -> 8

matches.forEach({ match in
    switch (match.tokenizer, match.text) {
    case (.word, let word): print("word:", word)
    case (.number, let number): print("number:", number)
    case (.emoji, let emoji): print("emoji:", emoji)
    case (.none, _): break
    }
})
// prints:
// number: 123
// emoji: 👩‍👩‍👦‍👦
// word: Hello
// word: world
// emoji: 👶
// word: again
// emoji: 👶🏿
// number: 45.67
````
