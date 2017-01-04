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

class DateTokenizer: TokenizerType, DefaultTokenizerType {

    // private properties
    private let _template = "00/00/00"
    private var _position: String.UnicodeScalarIndex
    private var _dateText: String
    private var _date: Date?

    // public property
    var date: Date {
        return _date!
    }

    // formatters are expensive, so only instantiate once for all tokenizers
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        return dateFormatter
    }()

    // called when we access `DateTokenizer.defaultTokenizer`
    required init() {
        _position = _template.unicodeScalars.startIndex
        _dateText = ""
    }

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

    var tokenIsComplete: Bool {
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

    // return an instance of tokenizer to return in matching tokens
    // we return a copy so that the instance keeps reference to the
    // dateText that has been matched, and the date that was parsed
    var tokenizerForMatch: TokenType {
        return DateTokenizer(text: _dateText, date: _date)
    }

    // only used by `tokenizerForMatch`
    private init(text: String, date: Date?) {
        _dateText = text
        _date = date
        _position = text.unicodeScalars.startIndex
    }
}
````

Combined with the technique used in the [type safety using a single tokenizer](Documentation/Type safety using a single tokenizer.md) the tokenizer element is cast to `DateTokenizer` so we can access the `date` property from the returned `Token`s:

````Swift
import Mustard

let messyInput = "Serial: #YF 1942-b 12/01/27 (Scanned) 12/03/27 (Arrived) ref: 99/99/99"

let dateTokens: [DateTokenizer.Token] = messyInput.tokens()
// dateTokens.count -> 2
// ('99/99/99' is not matched by `DateTokenizer`)
//
// first date
// dateTokens[0].text -> "12/01/27"
// dateTokens[0].tokenizer -> DateTokenizer()
// dateTokens[0].tokenizer.date -> Date(2027-12-01 05:00:00 +0000)
//
// last date
// dateTokens[1].text -> "12/03/27"
// dateTokens[1].tokenizer -> DateTokenizer()
// dateTokens[1].tokenizer.date -> Date(2027-12-03 05:00:00 +0000)
````
