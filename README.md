# Mustard

Mustard is a Swift library for tokenizing strings when separating a string by whitespace doesn't cut it.

## Quick start

Mustard extends `String` with the method `tokens(from: CharacterSet...)` which allows you to pass in one
or more character sets to use criteria to find tokens.

Here's an example that extracts any sequence of characters that are made up either from the digits 0-9, or by letters.

````Swift
import Mustard

let messy = "123Hello world&^45.67"

let tokens = messy.tokens(from: .decimalDigits, .letters)
// tokens.count -> 5
// tokens: [(tokenType: TokenType, text: String, range: Range<String.Index>)]
// tokens is an array tuples that contains the TokenType that matched the token,
// the actual text that was matched, and the range of the token in the original input.
//
// second token..
// tokens[1].tokenType -> CharacterSet.letters
// tokens[1].text -> "Hello"
// tokens[1].range -> Range<String.Index>(3..<8)
//
// last token..
// tokens[4].tokenType -> CharacterSet.decimalDigits
// tokens[4].text -> "67"
// tokens[4].range -> Range<String.Index>(19..<21)
````

## Creating your own Tokenizer

From the sample text `"123Hello world&^45.67"` the sequence of characters `45.67` are not recognized as a single
token because it contains the character `.` which isn't contained in `CharacterSet.decimalDigits`.

You can either use `union` and other set operations on character sets to create appropriate criteria for extracting tokens,
or you can create your own Tokenizers by implementing the `TokenType` protocol.

````Swift
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
````

Many implementations of TokenType will be simple, a protocol extension includes default implementation of all functions except for `func canInclude(scalar: UnicodeScalar) -> Bool` so that trivial TokenTypes may only need this single method.

### Example: CamelCaseToken

````Swift
struct CamelCaseToken: TokenType {

    // start of token is identified by an uppercase letter
    func isRequiredToStart(with scalar: UnicodeScalar) -> Bool? {
        return CharacterSet.uppercaseLetters.contains(scalar)
    }

    // all remaining characters must be lowercase letters
    func canInclude(scalar: UnicodeScalar) -> Bool {
        return CharacterSet.lowercaseLetters.contains(scalar)
    }
}
````

Using your own `TokenType` objects is similar to using a character sets:

````Swift
let words = "HelloWorld".tokens(from: CamelCaseToken.tokenizer)
// words.count -> 2
// words[0].text -> "Hello"
// words[1].text -> "World"
````

### Example: EmojiToken

Because a single emoji character may extend over [multiple code points](https://oleb.net/blog/2016/12/emoji-4-0/) and be represented as multiple unicode scalars, then there is no out of the box `CharacterSet` for matching emoji.

This is a good opportunity for creating a TokenType for matching sequences of scalar that are emoji.

````Swift
struct EmojiToken: TokenType {

    func isRequiredToStart(with scalar: UnicodeScalar) -> Bool? {
        return EmojiToken.isEmojiScalar(scalar)
    }

    func canInclude(scalar: UnicodeScalar) -> Bool {
        return EmojiToken.isEmojiScalar(scalar) || EmojiToken.isJoiner(scalar)
    }

    static func isJoiner(_ scalar: UnicodeScalar) -> Bool {
        return scalar == "\u{200D}" // ZWJ/Zero-width joiner
    }

    static func isEmojiScalar(_ scalar: UnicodeScalar) -> Bool {

        switch scalar {
        case
        "\u{0001F600}"..."\u{0001F64F}", // Emoticons
        "\u{0001F300}"..."\u{0001F5FF}", // Misc Symbols and Pictographs
        "\u{0001F680}"..."\u{0001F6FF}", // Transport and Map
        "\u{00002600}"..."\u{000026FF}", // Misc symbols
        "\u{00002700}"..."\u{000027BF}", // Dingbats
        "\u{0000FE00}"..."\u{0000FE0F}", // Variation Selectors
        "\u{0001F900}"..."\u{0001F9FF}", // Various (e.g. 🤖)
        "\u{0001F1E6}"..."\u{0001F1FF}": // regional flags
            return true

        default:
            return false
        }
    }
}

````

## Bundling multiple TokenType into a single enum

The tuple returned in the token results array has the signature `(tokenType: TokenType, text: String, range: Range<String.Index>)`
Because the protocol TokenType is used, your code becomes less expressive.

````Swift

let tokens = messy.tokens(from: .decimalDigits, .letters)

// neither of these blocks will be executed, but the complier has no way to know
if tokens[0].tokenType is EmojiToken {
    print("found emoji token")
}
else if tokens[0].tokenType is NumberToken {
    print("found number token")
}

````

For a little effort upfront, you can create a TokenType from an enum.
The enum can either manage it's own cases for different types, or you can re-use existing TokenType definitions:

````Swift
// bundle multiple TokenTypes into a single type
enum MixedToken: TokenType {

    case word
    case number
    case emoji
    case none

    init() {
        self = .other
    }

    static let wordToken = WordToken()
    static let numberToken = NumberToken()
    static let emojiToken = EmojiToken()

    func canInclude(scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedToken.wordToken.canInclude(scalar: scalar)
        case .number: return MixedToken.numberToken.canInclude(scalar: scalar)
        case .emoji: return MixedToken.emojiToken.canInclude(scalar: scalar)
        case .none:
            return false
        }
    }

    func tokenType(withStartingScalar scalar: UnicodeScalar) -> TokenType? {

        if let _ = MixedToken.wordToken.tokenType(withStartingScalar: scalar) {
            return MixedToken.word
        }
        else if let _ = MixedToken.numberToken.tokenType(withStartingScalar: scalar) {
            return MixedToken.number
        }
        else if let _ = MixedToken.emojiToken.tokenType(withStartingScalar: scalar) {
            return MixedToken.emoji
        }
        else {
            return nil
        }
    }
}
````

````Swift
// define your own type alias for your enum-based TokenType
typealias MixedMatch = (tokenType: MixedToken, text: String, range: Range<String.Index>)

// use the `tokens()` method to grab tokens
let matches: [MixedMatch] = "123👩‍👩‍👦‍👦Hello world👶 again👶🏿 45.67".tokens()

matches.forEach({ match in
    switch (match.token, match.text) {
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


## Roadmap
- [ ] Include detailed examples and documentation
- [ ] Ability to skip/ignore characters within match
- [ ] Include more advanced pattern matching for matching tokens
- [ ] Performance testing / benchmarking against Scanner
- [ ] Make project logo ಠ_ಠ

## Requirements

- Swift 3.0

## Author

Made with :heart: by [@permakittens](http://twitter.com/permakittens)

## Contributing

Feedback, or contributions for bug fixing or improvements are welcome. Feel free to submit a pull request or open an issue.

## License

MIT
