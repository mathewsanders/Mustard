# LiteralTokenizer: matching literal substrings

In examples so far, tokenizers have not kept any internal state. Each call made to `tokenCanTake(_:)` is evaluated typically by checking to see if the given scalar is contained in some character set, with a special case made for the first scalar in the substring.

This approach limits the ability to distinguish between *cat*, *cta* since they both start with the same scalar, and are both comprised of the CharacterSet with characters *'a'*, *'c'*, and *'t'*.

`LiteralTokenizer` is a more complex `TokenizerType` that receives a target `String` on initialization, and maintains an internal state of the current position between calls to `tokenCanTake(_:)` to check that each scalar received matches the target string in the current position.

Along with defining `tokenCanTake(_:)`, this tokenizer also provides alternate implementations for `tokenIsComplete()`, `completeTokenIsInvalid(:)`, and `prepareForReuse()`.

````Swift

// implementing as class rather than struct since `tokenCanTake(_:)` will have mutating effect.
final class LiteralTokenizer: TokenizerType {

    private let target: String
    private var position: String.UnicodeScalarIndex

    // initialize a tokenizer with the target String we're looking for
    init(target: String) {
        self.target = target
        self.position = target.unicodeScalars.startIndex
    }

    // instead of looking at a set of scalars, the order that the scalar occurs
    // is relevant for the token
    func tokenCanTake(_ scalar: UnicodeScalar) -> Bool {

        guard position < target.unicodeScalars.endIndex else {
            return false
        }

        // if the scalar matches the target scalar in the current position, then advance
        // the position and return true
        if scalar == target.unicodeScalars[position] {
            position = target.unicodeScalars.index(after: position)
            return true
        }
        else {
            return false
        }
    }

    // this token is only complete when we've called `canTake(_:)` with the correct sequence
    // of scalars such that `position` has advanced to the endIndex of the target
    var tokenIsComplete: Bool {
        return position == target.unicodeScalars.endIndex
    }

    // if we've matched the token completely, it should be invalid if the next scalar
    // matches a letter, this means that literal match of "cat" will not match "catastrophe"
    func completeTokenIsInvalid(whenNextScalarIs scalar: UnicodeScalar?) -> Bool {
        if let next = scalar {
            return !CharacterSet.letters.contains(next)
        }
        else {
            return false
        }
    }

    // tokenizer instances are re-used, in most cases this doesn't matter, but because we keep
    // an internal state, we need to reset this instance to start matching again
    func prepareForReuse() {
        position = target.unicodeScalars.startIndex
    }
}

````

An extension provides an alternate alias for creating instances of the literal tokenizer:

````Swift
extension String {
    // a convenience to allow us to use `"cat".literalToken` instead of `LiteralTokenizer("cat")`
    var literalToken: LiteralTokenizer {
        return LiteralTokenizer(target: self)
    }
}
````

This allows us to match tokens by specific words.

Note in this example that the text 'catastrophe' is not matched.

````Swift
let input = "the cat and the catastrophe duck"
let tokens = input.tokens(matchedWith: "cat".literalToken, "duck".literalToken)
tokens.count // -> 2

for token in tokens {
    print("-", "'\(token.text)'")
}
// prints ->
// - 'cat'
// - 'duck'

````

See [FuzzyMatchTokenTests.swift](/Mustard/MustardTests/FuzzyMatchTokenTests.swift) for a unit test that includes matching a literal String, but allowing some flexibility in the literal match by ignoring certain characters.
