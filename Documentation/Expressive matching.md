# Example: expressive matching

The results returned by `tokens(matchedWith:)`returns an array `Token` which in turn is a tuple with the signature `(tokenizer: TokenizerType, text: String, range: Range<String.Index>)`

To make use of the `tokenizer` element, you need to either use type casting (using `as?`) or type checking (using `is`) for the `tokenizer` element to be useful.

Maybe we want to filter out only tokens that were matched with a number tokenizer:

````Swift
import Mustard

let tokens = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)
// tokens.count -> 5

let numberTokens = tokens.filter({ $0.tokenizer is NumberTokenizer })
// numberTokens.count -> 0

````

This can lead to bugs in your logic-- in the example above `numberTokens` will be empty because the tokenizers used were  `CharacterSet.decimalDigits`, and `CharacterSet.letters`, so the filter won't match any of the tokens.

This may seem like an obvious error, but it's the type of unexpected bug that can slip in when we're using loosely typed results.

Thankfully, Mustard can return a strongly typed set of matches if a single `TokenizerType` is used:

````Swift
import Mustard

// call `tokens()` method on `String` to get matching tokens from the string
let numberTokens: [NumberTokenizer.Token] = "123Hello world&^45.67".tokens()
// numberTokens.count -> 2

````

Used in this way, this isn't very useful, but it does allow for multiple `TokenizerType` to be bundled together as a single tokenizer by implementing with an `enum`.

An enum tokenizer can either manage it's own internal state, or potentially act as a lightweight wrapper to other existing tokenizers.

Here's an example `TokenizerType` that acts as a wrapper for word, number, and emoji tokenizers:

````Swift
enum MixedTokenizer: TokenizerType {

    case word
    case number
    case emoji
    case none // 'none' case not strictly needed, and
              // in this implementation will never be matched
    init() {
        self = .none
    }

    static let wordTokenizer = WordTokenizer()
    static let numberTokenizer = NumberTokenizer()
    static let emojiTokenizer = EmojiTokenizer()

    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedTokenizer.wordTokenizer.tokenCanTake(scalar)
        case .number: return MixedTokenizer.numberTokenizer.tokenCanTake(scalar)
        case .emoji: return MixedTokenizer.emojiTokenizer.tokenCanTake(scalar)
        case .none:
            return false
        }
    }

    func token(startingWith scalar: UnicodeScalar) -> TokenizerType? {

        if let _ = MixedTokenizer.wordTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.word
        }
        else if let _ = MixedTokenizer.numberTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.number
        }
        else if let _ = MixedTokenizer.emojiTokenizer.token(startingWith: scalar) {
            return MixedTokenizer.emoji
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
public extension TokenizerType {
    typealias Token = (tokenizer: Self, text: String, range: Range<String.Index>)
}
````

Setting your results array to this type gives you the option to use the shorter `tokens()` method,
where Mustard uses the inferred type to perform tokenization.

Since the tokens array is strongly typed, you can be more expressive with the results, and the
complier can give you more hints to prevent you from making mistakes.

````Swift

// use the `tokens()` method to grab matching substrings using a single tokenizer
let tokens: [MixedTokenizer.Token] = "123👩‍👩‍👦‍👦Hello world👶 again👶🏿 45.67".tokens()
// tokens.count -> 8

tokens.forEach({ token in
    switch (token.tokenizer, token.text) {
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
