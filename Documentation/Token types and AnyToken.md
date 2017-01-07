## Token types and AnyToken

When matching a single tokenizer (or multiple tokenizers with the same type) tokens returned will be of the type associated with the tokenizer.

````Swift
let tokens = "123 456 abc def".tokens(matchedWith: .letters)
// tokens: [CharacterSet.Token]
// tokens.count -> 2
//
// token[1].text -> "abc"
// token[2].text -> "def"
````

When using multiple tokenizers of different types, you'll need to convert the tokenizers to `AnyTokenizer` first so that they are the same type.

Tokens returned from tokenizing with `AnyTokenizer` will have the protocol type `TokenType` but you can use type casting to access the specific instance or type checking to identify a particular type of token.

Here's an example using `DateTokenizer`, and `CharacterSet` together:

````Swift
let tokens = "12/01/17 123".tokens(matchedWith: DateTokenizer.defaultTokenizer, CharacterSet.decimalDigits.anyTokenizer)
// tokens: [TokenType]
// tokens.count -> 2

for token in tokens {

    switch token {
      // type check to see if token is a CharacterSet token
      case is CharacterSet.Token:
        print("digits are:", token.text)

      // type cast to access the `date` property
      case let dateToken as DateTokenizer.Token:
        print("date is:", dateToken.date)

      default: break
    }
}
// -> prints
// date is: 2017-12-01 05:00:00 +0000
// digits are: 123
````

Providing a custom `TokenType` can make your code more expressive, but it is entirely optional. If a tokenizer
does not define an associated token type, then the default type `AnyToken` will be used instead.

This means that it's entirely possible that two different tokenizers will return tokens with the type `AnyToken`.
To distinguish between types of `AnyToken` produced by different tokenizers, `AnyToken` provides a `tokenizerType`
property that identifies the tokenizers that created the token.

Here's an example of using the tokenizers `ThreeLetterWord` and `FourLetterWord` that both return `AnyToken` but uses `tokenizerType` to drive logic.

````Swift

let tokens: [AnyToken] = "one two three four five six seven 8 9 10"
        .tokens(matchedWith: ThreeLetterWord.defaultTokenzier, FourLetterWord.defaultTokenzier)

for token in tokens {

    switch token.tokenizerType {
      // token was made by `ThreeLetterWord` tokenizer
      case is ThreeLetterWord.Type:
        print("3 letters:", token.text)

      // token was made by `FourLetterWord` tokenizer
      case is FourLetterWord.Type:
        print("4 letters:", token.text)

    default: break
    }
}
// prints ->
// 3 letters: one
// 3 letters: two
// 4 letters: four
// 4 letters: five
// 3 letters: six

````
