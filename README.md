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

## More information

- [TallyType protocol: implementing your own tokenizer](Documentation/1. TallyType protocol.md)
- [Example: matching emoji](Documentation/2. Matching emoji.md)
- [Example: expressive matching using enums](Documentation/3. Expressive matching using enums.md)
- [Example: literal and template matching using tokens with internal state](Documentation/4. Tokens with internal state.md)

## Todo (0.1)
- [x] Include detailed examples and documentation
- [x] Ability to skip/ignore characters within match
- [x] Include more advanced pattern matching for matching tokens
- [ ] Make project logo ಠ_ಠ

## Roadmap

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
