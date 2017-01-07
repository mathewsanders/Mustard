# Mustard 🌭

[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/mathewsanders/Mustard/blob/master/LICENSE) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-EF5138%20.svg?style=flat)](https://swift.org/package-manager/)

Mustard is a Swift library for tokenizing strings when splitting by whitespace doesn't cut it.

## Quick start using character sets

Foundation includes the `String` method [`components(separatedBy:)`](https://developer.apple.com/reference/swift/string/1690777-components) that allows us to get substrings divided up by certain characters:

````Swift
let sentence = "hello 2017 year"
let words = sentence.components(separatedBy: .whitespace)
// words.count -> 3
// words = ["hello", "2017", "year"]
````  

Mustard provides a similar feature, but with the opposite approach, where instead of matching by separators you can match by one or more character sets, which is useful if separators simply don't exist:

````Swift
import Mustard

let sentence = "hello2017year"
let words = sentence.components(matchedWith: .letters, .decimalDigits)
// words.count -> 3
// words = ["hello", "2017", "year"]
````  

If you want more than just the substrings, you can use the `tokens(matchedWith: CharacterSet...)` method which will return an array of `TokenType`.

As a minimum, `TokenType` requires properties for text (the substring matched), and range (the range of the substring in the original string). When using CharacterSets as a tokenizer, the more specific type `CharacterSetToken` is returned, which includes the property `set` which contains the instance of CharacterSet that was used to create the match.

````Swift
import Mustard

let tokens = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)
// tokens: [CharacterSet.Token]
// tokens.count -> 5 (characters '&', '^', and '.' are ignored)
//
// second token..
// token[1].text -> "Hello"
// token[1].range -> Range<String.Index>(3..<8)
// token[1].set -> CharacterSet.letters
//
// last token..
// tokens[4].text -> "67"
// tokens[4].range -> Range<String.Index>(19..<21)
// tokens[4].set -> CharacterSet.decimalDigits
````

## Advanced matching with custom tokenizers

Mustard can do more than match from character sets. You can create your own tokenizers with more
sophisticated matching behavior by implementing the `TokenizerType` and `TokenType` protocols.

Here's an example of using `DateTokenizer` ([see example for implementation](Documentation/Template tokenizer.md)) that finds substrings that match a `MM/dd/yy` format.

`DateTokenizer` returns tokens with the type `DateToken`. Along with the substring text and range, `DateToken` includes a `Date` object corresponding to the date in the substring:

````Swift
import Mustard

let text = "Serial: #YF 1942-b 12/01/17 (Scanned) 12/03/17 (Arrived) ref: 99/99/99"

let tokens = text.tokens(matchedWith: DateTokenizer())
// tokens: [DateTokenizer.Token]
// tokens.count -> 2
// ('99/99/99' is *not* matched by `DateTokenizer` because it's not a valid date)
//
// first date
// tokens[0].text -> "12/01/17"
// tokens[0].date -> Date(2017-12-01 05:00:00 +0000)
//
// last date
// tokens[1].text -> "12/03/17"
// tokens[1].date -> Date(2017-12-03 05:00:00 +0000)
````

## Documentation & Examples

- [Greedy tokens and tokenizer order](Documentation/Greedy tokens and tokenizer order.md)
- [Token types and AnyToken](Documentation/Token types and AnyToken.md)
- [TokenizerType: implementing your own tokenizer](Documentation/TokenizerType protocol.md)
- [EmojiTokenizer: matching emoji substrings](Documentation/Matching emoji.md)
- [LiteralTokenizer: matching specific substrings](/Documentation/Literal tokenizer.md)
- [DateTokenizer: tokenizer based on template match](Documentation/Template tokenizer.md)
- [Alternatives to using Mustard](/Documentation/Alternatives to using Mustard.md)
- [Performance comparisons](/Documentation/Performance Comparisons.md)

## Roadmap
- [x] Include detailed examples and documentation
- [x] Ability to skip/ignore characters within match
- [x] Include more advanced pattern matching for matching tokens
- [x] Make project logo 🌭
- [x] Performance testing / benchmarking against Scanner
- [ ] Include interface for working with Character tokenizers

## Requirements

- Swift 3.0

## Author

Made with :heart: by [@permakittens](http://twitter.com/permakittens)

## Contributing

Feedback, or contributions for bug fixing or improvements are welcome. Feel free to submit a pull request or open an issue.

## License

MIT
