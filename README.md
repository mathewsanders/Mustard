# Mustard

Mustard is a Swift library for tokenizing strings when separating a string by whitespace doesn't cut it.

## Examples

Mustard adds the function `func tokens(from tokenizers: TokenType...) -> [Token]` to String allowing any String to  be split up by one or more `TokenType`.

Mustard also extends any `CharacterSet` to act as a `TokenType` making it really simple to start using Mustard.

````Swift
import Mustard

let messy = "123Hello world&^45.67"
let tokens = messy.tokens(from: .decimalDigits, .letters)
// tokens: [(tokenType: TokenType, text: String, range: Range<String.Index>)]
// tokens.count -> 5
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

In the example above the substring '45.67' is split into two separate tokens because the '.' character isn't within the set `CharacterSet.decimalDigits`.

To capture non whole numbers as tokens you could either define a character set:
`let numbers = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))`

or you could define your own definition of a token by implementing the `TokenType` protocol:

````Swift

struct NumberToken: TokenType {

    static private let characters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "."))

    // number token can include any character in 0...9 + '.'
    func tokenCanInclude(scalar: UnicodeScalar) -> Bool {
        return NumberToken.characters.contains(scalar)
    }

    // numbers must start with character 0...9
    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType? {
        guard CharacterSet.decimalDigits.contains(scalar) else {
            return nil
        }
        return NumberToken()
    }
}

````

Getting tokens using your own `TokenType` is similar to using a character set:

````Swift
import Mustard

let messy = "123Hello world&^45.67"
let numbers = messy.tokens(from: NumberToken.tokenizer)
// numbers: [(tokenType: TokenType, text: String, range: Range<String.Index>)]
// numbers.count -> 2
//
// first token..
// numbers[0].tokenType -> NumberToken()
// numbers[0].text -> "123"
// numbers[0].range -> Range<String.Index>(0..<3)
//
// last token..
// numbers[1].tokenType -> NumberToken()
// numbers[1].text -> "45.67"
// numbers[1].range -> Range<String.Index>(16..<21)
````

Creating a `NumberToken` is a trivial example where in most cases it's easier to use a character set, but unlike using a union of `CharacterSet.decimalDigits` and `CharacterSet(charactersIn: ".")`, this custom token type allows us to require a token to start with a more specific set of characters.

To highlight another example usage of this here's a TokenType for seperating words by camel case:

````Swift
struct CamelCaseToken: TokenType {

    // number token can include any letter character
    func tokenCanInclude(scalar: UnicodeScalar) -> Bool {
        return CharacterSet.uppercaseLetters.contains(scalar)
    }

    // numbers must start with an uppercase letter
    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType? {
        guard CharacterSet.uppercaseLetters.contains(scalar) else {
            return nil
        }
        return CamelCaseToken()
    }
}
````

````Swift
let words = "HelloWorld".tokens(from: CamelCaseToken.tokenizer)
// words: [(tokenType: TokenType, text: String, range: Range<String.Index>)]
// words.count -> 2
// words[0].text -> "Hello"
// words[1].text -> "World"
````

A more interesting example is a TokenType that allows matching of emoji characters.

Because a single emoji character can be made of multiple unicode scalars, Swift doesn't have a corresponding character set.

````Swift
struct EmojiToken: TokenType {

    func tokenCanInclude(scalar: UnicodeScalar) -> Bool {
        return EmojiToken.isEmojiScalar(scalar)
    }

    func tokenType(startingWith scalar: UnicodeScalar) -> TokenType? {
        guard EmojiToken.isEmojiScalar(scalar) else {
            return nil
        }
        return EmojiToken()
    }

    static func isEmojiScalar(_ scalar: UnicodeScalar) -> Bool {

        switch scalar {
        case "\u{200D}",                 // Zero-width joiner
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

It's also possible to use an `enum` to create a more complex `TokenType` that has different internal states, perhaps to bundle multiple types of token into a single type.

````Swift
enum MixedToken: TokenType {

    case word
    case number
    case emoji

    init() {
        self = .word
    }

    static let wordToken = WordToken()
    static let numberToken = NumberToken()
    static let emojiToken = EmojiToken()

    func allows(scalar: UnicodeScalar) -> Bool {
        switch self {
        case .word: return MixedToken.wordToken.allows(scalar: scalar)
        case .number: return MixedToken.numberToken.allows(scalar: scalar)
        case .emoji: return MixedToken.emojiToken.allows(scalar: scalar)
        }
    }

    func tokenizer(startingWith scalar: UnicodeScalar) -> TokenType? {
        if let _ = MixedToken.wordToken.tokenizer(startingWith: scalar) {
            return MixedToken.word
        }
        else if let _ = MixedToken.numberToken.tokenizer(startingWith: scalar) {
            return MixedToken.number
        }
        else if let _ = MixedToken.emojiToken.tokenizer(startingWith: scalar) {
            return MixedToken.emoji
        }
        return nil
    }
}
````

By defining a `typealias` for this type, you can call a convenience method `tokens()` that uses the derived type from the type alias so that the tokenType is your custom type instead of the generic `TokenType`.

````Swift
typealias MixedMatch = (tokenType: MixedToken, text: String, range: Range<String.Index>)

let matches: [MixedMatch] = "123👩‍👩‍👦‍👦Hello world👶 again👶🏿 45.67".tokens()

matches.forEach({ match in
    switch (match.token, match.text) {
    case (.word, let word): print("word:", word)
    case (.number, let number): print("number:", number)
    case (.emoji, let emoji): print("emoji:", emoji)
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
