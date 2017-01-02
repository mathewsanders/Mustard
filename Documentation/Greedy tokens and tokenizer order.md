# Greedy tokens and tokenizer order

Tokenizers are greedy. The order that tokenizers are passed into the `matches(from: TokenType...)` will effect how substrings are matched.

````Swift
import Mustard

let numbers = "03/29/17 36"
let matches = numbers.matches(from: CharacterSet.decimalDigits, DateToken.tokenizer)
// matches.count -> 4
//
// matches[0].text -> "03"
// matches[0].tokenizer -> CharacterSet.decimalDigits
//
// matches[1].text -> "29"
// matches[1].tokenizer -> CharacterSet.decimalDigits
//
// matches[2].text -> "17"
// matches[2].tokenizer -> CharacterSet.decimalDigits
//
// matches[3].text -> "36"
// matches[3].tokenizer -> CharacterSet.decimalDigits
````

To get expected behavior, the `matches` method should be called with more specific tokenizers placed before more general tokenizers:

````Swift
import Mustard

let numbers = "03/29/17 36"
let matches = numbers.matches(from: DateToken.tokenizer, CharacterSet.decimalDigits)
// matches.count -> 2
//
// matches[0].text -> "03/29/17"
// matches[0].tokenizer -> DateToken()
//
// matches[1].text -> "36"
// matches[1].tokenizer -> CharacterSet.decimalDigits
````

If the more specific tokenizer fails to match a token, the more general tokens still have a chance to perform matches:

````Swift
import Mustard

let numbers = "99/99/99 36"
let matches = numbers.matches(from: DateToken.tokenizer, CharacterSet.decimalDigits)
// matches.count -> 4
//
// matches[0].text -> "99"
// matches[0].tokenizer -> CharacterSet.decimalDigits
//
// matches[1].text -> "99"
// matches[1].tokenizer -> CharacterSet.decimalDigits
//
// matches[2].text -> "99"
// matches[2].tokenizer -> CharacterSet.decimalDigits
//
// matches[3].text -> "36"
// matches[3].tokenizer -> CharacterSet.decimalDigits
````
````
