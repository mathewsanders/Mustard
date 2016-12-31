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

## Creating your own Tokenizers

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

Many of these types will be trivial, here's an example for matching words by camel case:

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

## Roadmap
- [ ] Include detailed examples and documentation
- [ ] Ability to skip/ignore characters within match
- [ ] Include criteria for matching end-of-token
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
