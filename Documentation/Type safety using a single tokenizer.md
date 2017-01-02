# Type safety using a single tokenizer

When matching with multiple tokenizers, there is no choice but to return an array of `Token` where the tokenizer element is the of the type `TokenizerType`.

To make use of the `tokenizer` element, you need to either use type casting (using `as?`) or type checking (using `is`) to figure out what type of tokenizer matched the substring.

Maybe we want to filter tokens to include only those that were matched with using a `NumberTokenizer` tokenizer:

````Swift
import Mustard

let tokens = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)
// tokens.count -> 5

let numberTokens = tokens.filter({ $0.tokenizer is NumberTokenizer })
// numberTokens.count -> 0
````

While it's obvious to us why numberTokens is empty (the string was tokenized using two character sets -- not a `NumberTokenizer` instance), from the compliers perspective there isn't anything wrong here

This may seem like an obvious error, but it's the type of unexpected bug that can slip in when we're using loosely typed results.

Thankfully, Mustard can return a strongly typed set of matches if a single `TokenizerType` is used:

````Swift
import Mustard

let numberTokens: [NumberTokenizer.Token] = "123Hello world&^45.67".tokens()
// NumberTokenizer.Token: (tokenizer: NumberTokenizer, text: String, range: Range<String.Index>)
// numberTokens.count -> 2

// numberTokens[0].text -> "123"
// numberTokens[1].text -> "45.67"

````

Using the `NumberTokenizer.Token` (which Mustard creates for every `TokenizerType`) which has a more specific type signature allows you to also use the shorter `tokens()` method which infers the type of tokenizer to match substrings.

## Bundling multiple types safely

Achieving type-safety by limiting to a single `TokenizerType` may seem like a strong constraint for practical use, but
with a little overhead it's possible to create a tokenizer that acts as a lightweight wrapper to multiple tokenizers.

Here's an example `MixedTokenizer` that acts as a wrapper to existing word, number, and emoji tokenizers:

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

Now with the results of calling `tokens()` we can use switch to check what type of tokenizer was responsible for
matching the substring and the complier will give us useful warnings or errors if we miss a case, or attempt to
access a tokenizer type that isn't represented by `MixedTokenizer`:

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
