# Mustard 🌭

Mustard is a Swift library for tokenizing strings when splitting by whitespace doesn't cut it.

## Quick start using character sets

Foundation includes the `String` method [`components(separatedBy:)`](https://developer.apple.com/reference/swift/string/1690777-components) that allows us to get substrings divided up by certain characters:

````Swift
let sentence = "hello 2007 year"
let words = sentence.components(separatedBy: .whitespace)
// words.count -> 3
// words = ["hello", "2007", "year"]
````  

Mustard provides a similar feature, but with the opposite approach, where instead of matching by separators you can match by one or more character sets, which is useful if separators simply don't exist:

````Swift
let sentence = "hello2007year"
let words = sentence.components(matchedWith: .letters, .decimalDigits)
// words.count -> 3
// words = ["hello", "2007", "year"]
````  

If you want more than just the substrings, you can use the `tokens(matchedWith: CharacterSet...)` method which returns a tuple with the substring, range, and the CharacterSet responsible for matching the substring:

````Swift
import Mustard

let tokens: [Token] = "123Hello world&^45.67".tokens(matchedWith: .decimalDigits, .letters)
// typealias Token = (text: String, range: Range<String.Index>, tokenizer: TokenizerType)
// tokens.count -> 5 (characters '&', '^', and '.' are ignored)
//
// second token..
// token[1].text -> "Hello"
// token[1].range -> Range<String.Index>(3..<8)
// token[1].tokenizer -> CharacterSet.letters
//
// last token..
// tokens[4].text -> "67"
// tokens[4].range -> Range<String.Index>(19..<21)
// tokens[4].tokenizer -> CharacterSet.decimalDigits
````

## Expressive use with custom tokenizers

Rather than being limited to matching substrings from character sets, you can create your own tokenizers with more
sophisticated behavior by implementing the `TokenizerType` protocol.

Here's an example of using `DateTokenizer` ([see example](Documentation/Tokens with internal state.md) for implementation)
that matches substrings with a valid `MM/dd/yy` format, and at the same time exposes a `Date` object corresponding to the  date represented by the substring:

````Swift
import Mustard

let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/03/27 (Arrived) ref: 99/99/99"

let tokens: [DateTokenizer.Token] = messyInput.tokens()
// tokens.count -> 2
// ('99/99/99' is *not* matched by `DateTokenizer`)
//
// first date
// tokens[0].text -> "12/01/27"
// tokens[0].tokenizer -> DateTokenizer()
// tokens[0].tokenizer.date -> Date(2027-12-01 05:00:00 +0000)
//
// last date
// tokens[1].text -> "12/03/27"
// tokens[1].tokenizer -> DateTokenizer()
// tokens[1].tokenizer.date -> Date(2027-12-03 05:00:00 +0000)
````

## Documentation & Examples

- [Greedy tokens and tokenizer order](Documentation/Greedy tokens and tokenizer order.md)
- [TokenizerType: implementing your own tokenizer](Documentation/TokenizerType protocol.md)
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
