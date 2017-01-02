# Mustard 🌭

Mustard is a Swift library for tokenizing strings when splitting by whitespace doesn't cut it.

## Quick start using character sets

Mustard extends `String` with the method `matches(from: CharacterSet...)` which allows you to pass in one
or more character sets to use criteria to find substring matches using one or more character sets as tokenizers.

Here's an example that extracts any sequence of characters that are either letters or digits:

````Swift
import Mustard

let matches = "123Hello world&^45.67".matches(from: .decimalDigits, .letters)
// matches.count -> 5
// matches: [(tokenizer: TokenType, text: String, range: Range<String.Index>)]
// matches is an array of tuples which contains an instance of the TokenType that
// is responsible for the match, the actual text that was matched, and the range of the token
// in the original input.
//
// second token..
// matches[1].tokenizer -> CharacterSet.letters
// matches[1].text -> "Hello"
// matches[1].range -> Range<String.Index>(3..<8)
//
// last token..
// matches[4].tokenizer -> CharacterSet.decimalDigits
// matches[4].text -> "67"
// matches[4].range -> Range<String.Index>(19..<21)
````

## Expressive use with custom tokenizers

By creating types that implement the `TokenType` protocol we can create tokenizers with more sophisticated behaviors.

Here's some usage of a `DateToken` type ([see example](Documentation/Tokens with internal state.md) for implementation)
that matches tokens with the a valid `MM/dd/yy` format, and at the same time exposes a `date` property allowing access to a
corresponding `Date` object.

````Swift
import Mustard

let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/03/27 (Arrived) ref: 99/99/99"
let matches: [DateToken.Match] = messyInput.matches()
// matches.count -> 2
// ('99/99/99' is *not* matched by `DateToken`)
//
// first date
// matches[0].text -> "12/01/27"
// matches[0].tokenizer -> DateToken()
// matches[0].tokenizer.date -> Date(2027-12-01 05:00:00 +0000)
//
// last date
// matches[1].text -> "12/03/27"
// matches[1].tokenizer -> DateToken()
// matches[1].tokenizer.date -> Date(2027-12-03 05:00:00 +0000)
````

## Documentation & Examples

- [Greedy tokens and tokenizer order](Documentation/Greedy tokens and tokenizer order.md)
- [TallyType protocol: implementing your own tokenizer](Documentation/TallyType protocol.md)
- [Example: matching emoji](Documentation/Matching emoji.md)
- [Example: expressive matching](Documentation/Expressive matching.md)
- [Example: literal and template matching using tokens with internal state](Documentation/Tokens with internal state.md)

## Roadmap
- [x] Include detailed examples and documentation
- [x] Ability to skip/ignore characters within match
- [x] Include more advanced pattern matching for matching tokens
- [ ] Make project logo ಠ_ಠ
- [ ] Performance testing / benchmarking against Scanner
- [ ] Include interface for working with Character tokenizers

## Requirements

- Swift 3.0

## Author

Made with :heart: by [@permakittens](http://twitter.com/permakittens)

## Contributing

Feedback, or contributions for bug fixing or improvements are welcome. Feel free to submit a pull request or open an issue.

## License

MIT
