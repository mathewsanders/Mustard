# Greedy tokens and tokenizer order

Tokenizers are greedy. The order that tokenizers are passed into the `matches(from: AnyTokenizer...)` will effect how substrings are matched.

Here's an example using the `CharacterSet.decimalDigits` tokenizer and the custom tokenizer `DateTokenizer` that matches dates in the format `MM/dd/yy` ([see example](Template tokenizer.md) for implementation).

````Swift
import Mustard

let numbers = "36 03/29/17"
let tokens = numbers.tokens(matchedWith: CharacterSet.decimalDigits, DateTokenizer.defaultTokenizer)
// tokens.count -> 4
//
// tokens[0] -> CharacterSetToken
// tokens[0].set -> CharacterSet.decimalDigits
// tokens[0].text -> "36"
//
// tokens[1] -> CharacterSetToken
// tokens[1].set -> CharacterSet.decimalDigits
// tokens[1].text -> "03"
//
// tokens[2] -> CharacterSetToken
// tokens[2].set -> CharacterSet.decimalDigits
// tokens[2].text -> "29"
//
// tokens[3] -> CharacterSetToken
// tokens[3].set -> CharacterSet.decimalDigits
// tokens[3].text -> "17"

````

To get expected behavior, the `tokens` method should be called with more specific tokenizers placed before more general tokenizers:

````Swift
import Mustard

let numbers = "36 03/29/17"
let tokens = numbers.tokens(matchedWith: DateTokenizer.defaultTokenizer, CharacterSet.decimalDigits)
// tokens.count -> 2
//
// tokens[0] -> CharacterSetToken
// tokens[0].set -> CharacterSet.decimalDigits
// tokens[0].text -> "36"

// tokens[1] -> DateToken
// tokens[1].text -> "03/29/17"
// tokens[1].date -> Date(03/29/17)
````

If the more specific tokenizer `DateTokenizer` fails to match a token, the more general CharacterSet tokenizer still have a chance to perform matches:

````Swift
import Mustard

let numbers = "99/88/77 36"
let tokens = numbers.tokens(matchedWith: DateTokenizer.defaultTokenizer, CharacterSet.decimalDigits)
// tokens.count -> 4
//
// tokens[0] -> CharacterSetToken
// tokens[0].text -> "99"
//
// tokens[1].tokenizer -> CharacterSetToken
// tokens[1].text -> "88"
//
// tokens[2].tokenizer -> CharacterSetToken
// tokens[2].text -> "77"
//
// tokens[3].tokenizer -> CharacterSetToken
// tokens[3].text -> "36"

````
