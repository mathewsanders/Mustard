## DateTokenizer: matching against a template

Another useful pattern is to identify substrings that match a certain pattern.

`DateTokenizer` is a more complex `TokenizerType` that not only matches substrings with the format `MM/dd/yy`
but will also fail if the matched substring doesn't translate into a valid date (e.g. *'99/99/99'*).

Like the example covered in [matching a literal substring](Literal tokenizer.md), this tokenizer manages an internal
state between calls to `tokenCanTake(:)` to check that each scalar fits the criteria for the next scalar, but it also
exposes a property `date` which is the corresponding `Date` object for the matched substring.

````Swift

// convenience operator to make matching CharacterSet to scalar in a switch statement
infix operator ~=
func ~= (option: CharacterSet, input: UnicodeScalar) -> Bool {
    return option.contains(input)
}

final class DateTokenizer: TokenizerType, DefaultTokenizerType {

    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?

    // public property

    required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }

    // formatters are expensive, so only instantiate once for all DateTokens
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()

    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {

        guard _position < _template.unicodeScalars.endIndex else {
            // we've matched all of the template
            return false
        }

        switch (_template.unicodeScalars[_position], scalar) {
        case ("\u{0030}", CharacterSet.decimalDigits), // match with a decimal digit
             ("\u{002F}", "\u{002F}"):                 // match with the '/' character

            _position = _template.unicodeScalars.index(after: _position) // increment the template position
            _dateText.unicodeScalars.append(scalar) // add scalar to text matched so far
            return true

        default:
            return false
        }
    }

    func tokenIsComplete() -> Bool {
        if _position == _template.unicodeScalars.endIndex,
            let date = DateTokenizer.dateFormatter.date(from: _dateText) {
            // we've reached the end of the template
            // and the date text collected so far represents a valid
            // date format (e.g. not 99/99/99)

            _date = date
            return true
        }
        else {
            return false
        }
    }

    // reset the tokenizer for matching new date
    func prepareForReuse() {
        _dateText = ""
        _date = nil
        _position = _template.unicodeScalars.startIndex
    }

    // a specific TokenType that captures the date property
    struct DateToken: TokenType {
        let text: String
        let range: Range<String.Index>
        let date: Date
    }

    // called by mustard to create a token to use in results
    func makeToken(text: String, range: Range<String.Index>) -> DateToken {
        return DateToken(text: text, range: range, date: _date!)
    }
}
````

Since the tokenizer defines and returns it's own type of token, with the additional date property we can access this from the results:

````Swift
import Mustard

let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/03/27 (Arrived) ref: 99/99/99"

let dateTokens = messyInput.tokens(matchedWith: DateTokenizer())
// dateTokens: [DateTokenizer.Token]
//
// dateTokens.count -> 2
// ('99/99/99' is not matched by `DateTokenizer`)
//
// first date
// dateTokens[0].text -> "12/01/27"
// dateTokens[0].date -> Date(2027-12-01 05:00:00 +0000)
//
// last date
// dateTokens[1].text -> "12/03/27"
// dateTokens[1].date -> Date(2027-12-03 05:00:00 +0000)
````
