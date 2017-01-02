# Mustard 🌭

Mustard is a Swift library for tokenizing strings when splitting by whitespace doesn't cut it.

## Quick start using character sets

Mustard extends `String` with the method `tokens(from: CharacterSet...)` which allows you to pass in one
or more character sets to use criteria to find tokens.

Here's an example that extracts any sequence of characters that are either letters or digits:

````Swift
import Mustard

let messy = "123Hello world&^45.67"

let tokens = messy.tokens(from: .decimalDigits, .letters)
// tokens.count -> 5
// tokens: [(tokenizer: TokenType, text: String, range: Range<String.Index>)]
// tokens is an array of tuples which contains an instance of the TokenType that
// matched the token, the actual text that was matched, and the range of the token
// in the original input.
//
// second token..
// tokens[1].tokenizer -> CharacterSet.letters
// tokens[1].text -> "Hello"
// tokens[1].range -> Range<String.Index>(3..<8)
//
// last token..
// tokens[4].tokenizer -> CharacterSet.decimalDigits
// tokens[4].text -> "67"
// tokens[4].range -> Range<String.Index>(19..<21)
````

## Expressive use with custom tokenizers

By creating types that implement the `TokenType` protocol we can create tokenizers with more sophisticated behaviors.

Here's some usage of a `DateToken` type ([see example](Documentation/4. Tokens with internal state.md) for implementation)
that matches tokens with the a valid `MM/dd/yy` format, and at the same time exposes a `date` property allowing access to a
corresponding `Date` object.

````Swift
import Mustard

let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/03/27 (Arrived) ref: 99/99/99"
let tokens: [DateToken.Token] = messyInput.tokens()
// tokens.count -> 2
// ('99/99/99' is *not* matched by `DateToken`)
//
// first date
// tokens[0].text -> "12/01/27"
// tokens[0].tokenizer -> DateToken()
// tokens[0].tokenizer.date -> Date(2027-12-01 05:00:00 +0000)
//
// last date
// tokens[1].text -> "12/03/27"
// tokens[1].tokenizer -> DateToken()
// tokens[1].tokenizer.date -> Date(2027-12-03 05:00:00 +0000)
````

## Tokenizers are greedy

Tokenizers are greedy. The order that tokenizers are passed into the `tokens(from: TokenType...)` will effect the tokens
that are matched.

````Swift
import Mustard

let numbers = "03/29/2017 36"
let tokens = numbers.tokens(from: CharacterSet.decimalDigits, DateToken.tokenizer)
// tokens.count -> 4
//
// tokens[0].text -> "03"
// tokens[0].tokenizer -> CharacterSet.decimalDigits
//
// tokens[1].text -> "29"
// tokens[1].tokenizer -> CharacterSet.decimalDigits
//
// tokens[2].text -> "2017"
// tokens[2].tokenizer -> CharacterSet.decimalDigits
//
// tokens[3].text -> "36"
// tokens[3].tokenizer -> CharacterSet.decimalDigits
````

Typically to get expected behavior, the most specific tokenizers should be earlier in the list of tokenizers:

````Swift
import Mustard

let numbers = "03/29/2017 36"
let tokens = numbers.tokens(from: DateToken.tokenizer, CharacterSet.decimalDigits)
// tokens.count -> 2
//
// tokens[0].text -> "03/29/2017"
// tokens[0].tokenizer -> DateToken()
//
// tokens[1].text -> "36"
// tokens[1].tokenizer -> CharacterSet.decimalDigits
````

## More information

- [TallyType protocol: implementing your own tokenizer](Documentation/1. TallyType protocol.md)
- [Example: matching emoji](Documentation/2. Matching emoji.md)
- [Example: expressive matching](Documentation/3. Expressive matching.md)
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
