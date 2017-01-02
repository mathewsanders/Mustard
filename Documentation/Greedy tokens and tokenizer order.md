# Greedy tokens and tokenizer order

Tokenizers are greedy. The order that tokenizers are passed into the `matches(from: TokenizerType...)` will effect how substrings are matched.

Here's an example using the `CharacterSet.decimalDigits` tokenizer and the custom tokenizer `DateTokenizer` that matches dates in the format `MM/dd/yy` ([see example](Tokens with internal state.md) for implementation).

````Swift
import Mustard

let numbers = "03/29/17 36"
let tokens = numbers.tokens(matchedWith: CharacterSet.decimalDigits, DateTokenizer.defaultTokenizer)
// tokens.count -> 4
//
// tokens[0].text -> "03"
// tokens[0].tokenizer -> CharacterSet.decimalDigits
//
// tokens[1].text -> "29"
// tokens[1].tokenizer -> CharacterSet.decimalDigits
//
// tokens[2].text -> "17"
// tokens[2].tokenizer -> CharacterSet.decimalDigits
//
// tokens[3].text -> "36"
// tokens[3].tokenizer -> CharacterSet.decimalDigits
````

To get expected behavior, the `tokens` method should be called with more specific tokenizers placed before more general tokenizers:

````Swift
import Mustard

let numbers = "03/29/17 36"
let tokens = numbers.tokens(matchedWith: DateTokenizer.defaultTokenizer, CharacterSet.decimalDigits)
// tokens.count -> 2
//
// tokens[0].text -> "03/29/17"
// tokens[0].tokenizer -> DateTokenizer()
//
// tokens[1].text -> "36"
// tokens[1].tokenizer -> CharacterSet.decimalDigits
````

If the more specific tokenizer fails to match a token, the more general tokens still have a chance to perform matches:

````Swift
import Mustard

let numbers = "99/99/99 36"
let tokens = numbers.tokens(matchedWith: DateTokenizer.defaultTokenizer, CharacterSet.decimalDigits)
// tokens.count -> 4
//
// tokens[0].text -> "99"
// tokens[0].tokenizer -> CharacterSet.decimalDigits
//
// tokens[1].text -> "99"
// tokens[1].tokenizer -> CharacterSet.decimalDigits
//
// tokens[2].text -> "99"
// tokens[2].tokenizer -> CharacterSet.decimalDigits
//
// tokens[3].text -> "36"
// tokens[3].tokenizer -> CharacterSet.decimalDigits
````
